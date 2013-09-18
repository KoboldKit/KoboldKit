/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTilemapLayerContourTracer.h"
#import "KKPointArray.h"
#import "KKIntegerArray.h"
#import "KKTilemap.h"
#import "KKTilemapLayer.h"

const uint16_t kBlockMapBorder = 0xffff;
const uint16_t kBlockMapUntracedBlocking = 0xfffe;
static NSInteger neighborOffsets[8];


@implementation KKTilemapLayerContourTracer

+(id) contourMapFromTileLayer:(KKTilemapLayer*)layer
{
	return [[self alloc] initFromTileLayer:layer blockingGids:nil];
}

+(id) contourMapFromTileLayer:(KKTilemapLayer*)layer blockingGids:(KKIntegerArray*)blockingGids
{
	return [[self alloc] initFromTileLayer:layer blockingGids:blockingGids];
}

-(id) initFromTileLayer:(KKTilemapLayer*)layer blockingGids:(KKIntegerArray*)blockingGids
{
	self = [super init];
	if (self)
	{
		_layer = layer;

		// map borders (tiles outside of map boundary) are considered blocking
		_mapBorderBlocking = YES;
		_tileSize = _layer.tilemap.gridSize;
		_layerSize = _layer.size;
		
		_blockingGids = blockingGids;
		_contourTiles = [NSMutableArray arrayWithCapacity:10];
		_contourSegments = [NSMutableArray arrayWithCapacity:10];
		[self traceContours];
		
		_layer = nil;
	}
	return self;
}

-(void) dealloc
{
	[self freeBlockMap];
}

-(void) traceContours
{
	[self createBlockMap];
	//[self dumpBlockMap];
	
	// offset indices (relative to a certain tile) in clockwise order, beginning with the tile to the left
	neighborOffsets[0] = -1;
	neighborOffsets[1] = -(_blockMapSize.width + 1);
	neighborOffsets[2] = -_blockMapSize.width;
	neighborOffsets[3] = -(_blockMapSize.width - 1);
	neighborOffsets[4] = 1;
	neighborOffsets[5] = _blockMapSize.width + 1;
	neighborOffsets[6] = _blockMapSize.width;
	neighborOffsets[7] = _blockMapSize.width - 1;
	
	NSLog(@"Moore neighbor tracing begins ...");
	
	// unique ID for each contour for the blocking map (1 is regular, untraced blocking, 0 is free tile)
	NSUInteger contourBlockID = 2;
	NSUInteger currentTile = _currentStartTile = [self nextTileStartingAt:[self nextTileStartingAt:0 blocking:NO] blocking:YES];
	
	// TODO:
	// find a surrounding free block from blocking tile, if none found search for next block tile
	// if free block found, use that free block as initial backtrack tile
	
	// trace A contour, something's wrong at around 0,4
	
	while (currentTile != 0)
	{
		// find first non-blocking tile, then find first blocking tile after that
		NSUInteger boundaryTile = currentTile;
		//NSLog(@"Initial boundary at : %@", [self coordStringFromIndex:boundaryTile]);
		
		// first backtrack tile is the one to the left
		NSUInteger backtrackTile = _currentBacktrackTile = [self firstFree4WayNeighborForTile:boundaryTile];
		if (backtrackTile == 0)
		{
			// start again
			//NSLog(@"\tSelected boundary has no surrounding free tiles, skipping.");
			currentTile = _currentStartTile = [self nextTileStartingAt:[self nextTileStartingAt:currentTile blocking:NO] blocking:YES];
			if (currentTile < boundaryTile)
			{
				// never go back
				break;
			}
			continue;
		}
		//NSLog(@"Initial backtrack at: %@", [self coordStringFromIndex:backtrackTile]);
		
		// get the first Moore neighbor tile
		KKNeighborIndices initialBacktrackNeighborIndex = [self neighborIndexForBoundary:boundaryTile backtrack:backtrackTile];
		KKNeighborIndices neighborIndex = initialBacktrackNeighborIndex + 1;
		NSUInteger neighborTestCount = 1;
		NSUInteger neighborTile = _currentNeighborTile = boundaryTile + neighborOffsets[neighborIndex];
		//NSLog(@"Initial neighbor at: %@ %@", [self coordStringFromIndex:neighborTile], [self nameForNeighborIndex:neighborIndex]);
		
		// remember the start tile and the tile it was entered from (backtrack) for the termination condition
		NSUInteger startTileVisitCount = 0;
		NSUInteger contourStartTile = boundaryTile;
		NSUInteger backtrackStartTile = backtrackTile;
		
		// create tile index array and add the first contour tile to it
		KKIntegerArray* contourTileGids = [KKIntegerArray integerArrayWithCapacity:8];
		[_contourTiles addObject:contourTileGids];
		[contourTileGids addInteger:contourStartTile];
		
		// create segments array
		KKPointArray* contourSegment = [KKPointArray pointArrayWithCapacity:8];
		[_contourSegments addObject:contourSegment];
		
		//NSLog(@"BEGIN LOOP .......");
		
		while (YES)
		{
			/*
			[self dumpBlockMap];
			NSLog(@"neighbor: %@ [%@] - BLOCKING: %@", [self coordStringFromIndex:neighborTile], [self nameForNeighborIndex:neighborIndex], _blockMap[neighborTile] ? @"YES" : @"NO");
			[NSThread sleepForTimeInterval:0.04];
			 */
			
			// is the current neighbor tile blocking?
			if (_blockMap[neighborTile])
			{
				[self addPointsToSegments:contourSegment boundary:boundaryTile fromNeighborIndex:initialBacktrackNeighborIndex toNeighborIndex:neighborIndex];

				// mark the field as traced
				_blockMap[neighborTile] = contourBlockID;
				
				boundaryTile = neighborTile;
				[contourTileGids addInteger:boundaryTile];
				//NSLog(@"\tNew BOUNDARY at: %@", [self coordStringFromIndex:boundaryTile]);
				//NSLog(@"\tBacktracking to: %@", [self coordStringFromIndex:backtrackTile]);
				
				// (backtrack: move the current pixel c to the pixel from which p was entered)
				initialBacktrackNeighborIndex = [self neighborIndexForBoundary:boundaryTile backtrack:backtrackTile];
				neighborIndex = (initialBacktrackNeighborIndex + 1) % 8;
				neighborTestCount = 0;
				neighborTile = _currentNeighborTile = boundaryTile + neighborOffsets[neighborIndex];
				//NSLog(@"\tNew neighbor at : %@ %@", [self coordStringFromIndex:neighborTile], [self nameForNeighborIndex:neighborIndex]);
				
				// uncomment this and set a breakpoint to see the map tracing contours tile after tile
				//[self dumpBlockMap];
			}
			else
			{
				// did we loop around a single blocking tile once?
				if (neighborTestCount == 7)
				{
					//NSLog(@"Found single block tile at %@", [self coordStringFromIndex:boundaryTile]);
					break;
				}
				
				// (advance the current pixel c to the next clockwise pixel in M(p) and update backtrack)
				backtrackTile = _currentBacktrackTile = neighborTile;
				neighborIndex = (neighborIndex + 1) % 8;
				neighborTile = _currentNeighborTile = boundaryTile + neighborOffsets[neighborIndex];
				neighborTestCount++;
			}
			
			if (neighborTile == contourStartTile)
			{
				startTileVisitCount++;
				if (startTileVisitCount > 2 || backtrackTile == backtrackStartTile)
				{
					//NSLog(@"Returned to starting boundary, quitting!");
					//NSLog(@"\ttart tile at: %@", [self coordStringFromIndex:contourStartTile]);
					//NSLog(@"\tbacktrack at: %@", [self coordStringFromIndex:backtrackStartTile]);
					break;
				}
			}
		}

		// add the remaining segments
		[self addPointsToSegments:contourSegment boundary:boundaryTile fromNeighborIndex:initialBacktrackNeighborIndex toNeighborIndex:neighborIndex];
		[self closeContour:contourSegment];

		// dump the newly added contour and remaining blocking tiles
		//[self dumpBlockMap];

		// find the next free tile and trace that
		currentTile = _currentStartTile = [self nextTileStartingAt:[self nextTileStartingAt:currentTile blocking:NO] blocking:YES];
		contourBlockID++;
	}

	_currentStartTile = -1;
	_currentNeighborTile = -1;
	_currentBacktrackTile = -1;
	[self dumpBlockMap];

	[self convertSegmentsToPath];
	//NSLog(@"Exiting, all tiles processed.");
}

-(void) addPointsToSegments:(KKPointArray*)segments boundary:(NSUInteger)boundaryTile fromNeighborIndex:(KKNeighborIndices)fromNeighbor toNeighborIndex:(KKNeighborIndices)toNeighbor
{
	CGPoint boundaryCoords = [self tileCoordForBlockMapIndex:boundaryTile];
	boundaryCoords.y = _layerSize.height - 1 - boundaryCoords.y;

	for (KKNeighborIndices neighbor = fromNeighbor; neighbor != toNeighbor; neighbor = (neighbor + 1) % 8)
	{
		BOOL isPointValid = YES;
		CGPoint newPoint;
		
		switch (neighbor)
		{
			case KKNeighborLeft:
				newPoint = CGPointMake(boundaryCoords.x * _tileSize.width, boundaryCoords.y * _tileSize.height);
				break;
			case KKNeighborUp:
				newPoint = CGPointMake(boundaryCoords.x * _tileSize.width, boundaryCoords.y * _tileSize.height + _tileSize.height);
				break;
			case KKNeighborRight:
				newPoint = CGPointMake(boundaryCoords.x * _tileSize.width + _tileSize.width, boundaryCoords.y * _tileSize.height + _tileSize.height);
				break;
			case KKNeighborDown:
				newPoint = CGPointMake(boundaryCoords.x * _tileSize.width + _tileSize.width, boundaryCoords.y * _tileSize.height);
				break;
				
			default:
				// diagonal neighbors don't add any points
				isPointValid = NO;
				break;
		}

		if (isPointValid)
		{
			if (segments.count >= 2)
			{
				// check if the new point is on the same segment (axis) as the last two points
				CGPoint segmentStart = segments.points[segments.count - 2];
				CGPoint segmentEnd = segments.points[segments.count - 1];
				if ([self isPointOnSameLine:newPoint segmentStart:segmentStart segmentEnd:segmentEnd])
				{
					// replace previous segment's end point
					segments.points[segments.count -1] = newPoint;
				}
				else
				{
					// add as new point
					[segments addPoint:newPoint];
				}
			}
			else
			{
				// first two points are always added unconditionally
				[segments addPoint:newPoint];
			}
		}
	}
}

-(void) closeContour:(KKPointArray*)segments
{
	// some contours may be traced more than once, find and remove repeating patterns
	NSUInteger sequenceLength = 0;
	NSUInteger equalPointsCount = 0;
	CGPoint firstPoint = segments.points[0];
	for (NSUInteger i = 1; i < segments.count; i++)
	{
		CGPoint point = segments.points[i];

		if (sequenceLength)
		{
			CGPoint comparePoint = segments.points[i - sequenceLength];
			if (CGPointEqualToPoint(point, comparePoint))
			{
				// the pattern is repeating so far
				equalPointsCount++;
			}
			else
			{
				// false alarm, sometimes the first point may be visited again without repeat
				sequenceLength = 0;
				equalPointsCount = 0;
			}
			
			// did we match an entire repeating sequence once?
			if (sequenceLength > 0 && equalPointsCount == sequenceLength)
			{
				// remove all the repeating points
				[segments removePointsStartingAtIndex:sequenceLength];
				break;
			}
		}
		
		// try to find the first point again
		if (sequenceLength == 0 && CGPointEqualToPoint(point, firstPoint))
		{
			// now all following points must match sequenceLength times, then it is a repeating pattern
			sequenceLength = i;
		}
	}

	// ensure that first and last point are not equal
	CGPoint lastPoint = [segments lastPoint];
	if (CGPointEqualToPoint(firstPoint, lastPoint))
	{
		// remove the last point
		[segments removeLastPoint];
	}
	
	// check if the first two points' segment and the last point are on the same line
	if (segments.count >= 3)
	{
		lastPoint = [segments lastPoint];
		CGPoint segmentStart = segments.points[1];
		CGPoint segmentEnd = segments.points[0];
		if ([self isPointOnSameLine:lastPoint segmentStart:segmentStart segmentEnd:segmentEnd])
		{
			// first point becomes the last point, and the last point deleted
			segments.points[0] = lastPoint;
			[segments removeLastPoint];
		}
		
		// test if the second to last and last point are on the same line as the first point
		segmentStart = segments.points[segments.count - 2];
		segmentEnd = [segments lastPoint];
		if ([self isPointOnSameLine:firstPoint segmentStart:segmentStart segmentEnd:segmentEnd])
		{
			[segments removeLastPoint];
		}
	}

	// ensure that last point equals first point to close the shape
	firstPoint = segments.points[0];
	lastPoint = [segments lastPoint];
	if (CGPointEqualToPoint(firstPoint, lastPoint) == NO)
	{
		// add the first point again to close the segment chain
		[segments addPoint:firstPoint];
	}
}

-(void) convertSegmentsToPath
{
DEVELOPER_FIXME("create CGPathRef within algorithm")
	
	NSMutableArray* pathSegments = [NSMutableArray arrayWithCapacity:_contourSegments.count];
	for (KKPointArray* contour in _contourSegments)
	{
		CGMutablePathRef path = CGPathCreateMutable();
		
		for (NSUInteger i = 0; i < contour.count; i++)
		{
			CGPoint p = contour.points[i];
			
			if (i == 0)
			{
				CGPathMoveToPoint(path, nil, p.x, p.y);
			}
			else
			{
				CGPathAddLineToPoint(path, nil, p.x, p.y);
			}
		}
		
		[pathSegments addObject:(__bridge_transfer id)path];
	}
	
	_contourSegments = pathSegments;
}

-(BOOL) isPointOnSameLine:(CGPoint)point segmentStart:(CGPoint)segmentStart segmentEnd:(CGPoint)segmentEnd
{
	return (segmentStart.x == segmentEnd.x && segmentStart.x == point.x) || (segmentStart.y == segmentEnd.y && segmentStart.y == point.y);
}

-(BOOL) isBlockingGid:(gid_t)gid
{
	if (_blockingGids)
	{
		NSUInteger numBlockingGids = _blockingGids.count;
		NSUInteger* blockingGids = _blockingGids.integers;
		
		for (NSUInteger i = 0; i < numBlockingGids; i++)
		{
			if (blockingGids[i] == gid)
			{
				return YES;
			}
		}
		
		return NO;
	}
	
	return (gid != 0);
}

// returns the neighbor index between these two tiles
// ie if the backtrack is to the left of boundary, index == 0
-(KKNeighborIndices) neighborIndexForBoundary:(NSUInteger)boundaryTile backtrack:(NSUInteger)backtrackTile
{
	KKNeighborIndices index = 0;
	for (; index < KKNeighborIndices_Count; index++)
	{
		if (boundaryTile + neighborOffsets[index] == backtrackTile)
		{
			break;
		}
	}
	
	//NSLog(@"\tn-idx: %u (%@) for %@ => %@", index, [self nameForNeighborIndex:index], [self coordStringFromIndex:boundaryTile], [self coordStringFromIndex:backtrackTile]);
	
	return index;
}

-(void) createBlockMap
{
	// free ensures the function is reentrent, correctly replacing any previously existing array
	[self freeBlockMap];

	// calloc ensures the array is initialized with zeros
	// this could be a bitarray to conserve memory
	NSUInteger width = _layerSize.width + 2;
	NSUInteger height = _layerSize.height + 2;
	_blockMapSize = CGSizeMake(width, height);
	_blockMapCount = width * height;
	_blockMap = calloc(_blockMapCount, sizeof(uint16_t));
	
	for (NSInteger y = 0; y < _blockMapSize.height; y++)
	{
		for (NSInteger x = 0; x < _blockMapSize.width; x++)
		{
			if (x == 0 || y == 0 || x > _layerSize.width || y > _layerSize.height)
			{
				// the outer borders contain a special blocking bit
				if (_mapBorderBlocking)
				{
					_blockMap[y * width + x] = kBlockMapBorder;
				}
			}
			else
			{
				// test the tile at the given (tilemap) coord and see if it's blocking or not
				uint32_t myGID = [_layer tileGidAt:CGPointMake(x - 1, y - 1)];
				if ([self isBlockingGid:myGID])
				{
					_blockMap[y * width + x] = kBlockMapUntracedBlocking;
				}
			}
		}
	}
}

-(void) freeBlockMap
{
	free(_blockMap);
	_blockMap = nil;
}

-(BOOL) isOutOfBoundsTile:(NSUInteger)index
{
	// skip all tiles at the outer boundary
	CGPoint pos = [self tileCoordForBlockMapIndex:index];
	return (pos.x < 0 || pos.y < 0 || pos.x == _blockMapSize.width - 2 || pos.y == _blockMapSize.height - 2);
}

-(NSUInteger) firstFree4WayNeighborForTile:(NSUInteger)tile
{
	// test the 4-way connected tiles and return the first free one, or 0 if there's none
	NSUInteger freeTile = 0;
	for (NSUInteger i = 0; i < 8; i += 2)
	{
		NSUInteger testTile = tile + neighborOffsets[i];
		if ([self isOutOfBoundsTile:testTile])
		{
			continue;
		}
		
		CGPoint coord = [self tileCoordForBlockMapIndex:testTile];
		uint32_t gid = [_layer tileGidAt:coord];
		
		if ([self isBlockingGid:gid] == NO)
		{
			freeTile = testTile;
			break;
		}
	}
	
	return freeTile;
}

-(NSUInteger) nextTileStartingAt:(NSUInteger)index blocking:(BOOL)blocking
{
	for (NSUInteger i = index; i < _blockMapCount; i++)
	{
		// skip all tiles at the outer boundary
		if (_blockMap[i] == kBlockMapBorder)
		{
			continue;
		}
		
		if ((blocking == NO && _blockMap[i] == 0) ||
			(blocking == YES && _blockMap[i] == kBlockMapUntracedBlocking))
		{
			//NSLog(@"next %@ tile: %@", blocking ? @"BLOCK" : @"FREE", [self coordStringFromIndex:i]);
			return i;
		}
	}
	
	return 0;
}

-(CGPoint) tileCoordForIndex:(NSUInteger)index
{
	NSUInteger width = _layerSize.width;
	return CGPointMake(index % width, index / width);
}

-(CGPoint) tileCoordForBlockMapIndex:(NSUInteger)index
{
	NSUInteger width = _blockMapSize.width;
	return CGPointMake((NSInteger)(index % width) - 1, (NSInteger)(index / width) - 1);
}


#pragma mark DEBUG Helper

// shorthand for better debug output
-(CGPoint) coord:(NSUInteger)index
{
	return [self tileCoordForBlockMapIndex:index];
}

-(NSString*) coordStringFromIndex:(NSUInteger)index
{
	CGPoint coord = [self coord:index];
	return [NSString stringWithFormat:@"[%lu]=(%.0f,%.0f)", (unsigned long)index, coord.x, coord.y];
}

-(NSString*) nameForNeighborIndex:(KKNeighborIndices)index
{
	NSString* name;
	
	switch (index)
	{
		case KKNeighborLeft:
			name = @"LEFT";
			break;
		case KKNeighborUpLeft:
			name = @"UPLEFT";
			break;
		case KKNeighborUp:
			name = @"UP";
			break;
		case KKNeighborUpRight:
			name = @"UPRIGHT";
			break;
		case KKNeighborRight:
			name = @"RIGHT";
			break;
		case KKNeighborDownRight:
			name = @"DOWNRIGHT";
			break;
		case KKNeighborDown:
			name = @"DOWN";
			break;
		case KKNeighborDownLeft:
			name = @"DOWNLEFT";
			break;
			
		default:
			name = @"INVALID INDEX!!!!";
			break;
	}
	
	return name;
}

-(void) dumpBlockMap
{
	NSMutableString* str = [NSMutableString stringWithCapacity:_blockMapCount];
	[str appendString:@"BlockMap:\n\n"];
	for (NSUInteger i = 0; i < _blockMapCount; i++)
	{
		if (i > 0 && i % ((NSUInteger)_blockMapSize.width) == 0)
		{
			[str appendString:@"\n"];
		}
		
		[str appendString:[self dumpCharacterForBlockMapIndex:i]];
		[str appendString:@" "];
	}
	
	NSLog(@"%@\n\n", str);
}

-(NSString*) dumpCharacterForBlockMapIndex:(NSUInteger)index
{
	NSString* blockChar = nil;
	
	if (index == _currentStartTile)
	{
		blockChar = @"#";
	}
	else if (index == _currentNeighborTile)
	{
		blockChar = @"n";
	}
	else if (index == _currentBacktrackTile)
	{
		blockChar = @"b";
	}
	else if (_blockMap[index])
	{
		char contourChar = 'A';
		for (KKIntegerArray* contourIndices in _contourTiles)
		{
			for (NSUInteger contourIndex = 0; contourIndex < contourIndices.count; contourIndex++)
			{
				if (contourIndices.integers[contourIndex] == index)
				{
					blockChar = [NSString stringWithFormat:@"%c", contourChar]; // uppercase letters
					break;
				}
			}
	
			contourChar++;
			if (blockChar)
			{
				break;
			}
		}
		
		if (blockChar == nil)
		{
			if ([self isOutOfBoundsTile:index])
			{
				blockChar = @"x";
			}
			else if (_blockMap[index] == kBlockMapUntracedBlocking)
			{
				blockChar = @"+";
			}
		}
	}
	else
	{
		blockChar = @".";
	}
	
	return blockChar;
}

@end
