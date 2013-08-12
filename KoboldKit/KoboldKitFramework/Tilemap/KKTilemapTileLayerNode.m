//
//  KKTilemapTileLayerNode.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKTilemapTileLayerNode.h"
#import "KKTilemap.h"
#import "KKTilemapLayer.h"
#import "KKTilemapTileset.h"
#import "KKTilemapLayerTiles.h"
#import "KKMacros.h"

@implementation KKTilemapTileLayerNode

+(id) tileLayerNodeWithLayer:(KKTilemapLayer*)layer
{
	return [[self alloc] initWithLayer:layer];
}

-(void) didMoveToParent
{
	NSLog(@"Tile layer: %@", _layer.name);
	
	CGSize sceneSize = self.scene.size;
	CGSize gridSize = _tilemap.gridSize;
	CGSize mapSize = _tilemap.size;
	
	_visibleTilesOnScreen = CGSizeMake(ceil(sceneSize.width / gridSize.width + 1), ceil(sceneSize.height / gridSize.height + 1));
	_viewBoundary = CGSizeMake(-(mapSize.width * gridSize.width - (_visibleTilesOnScreen.width - 1) * gridSize.width),
							   -(mapSize.height * gridSize.height - (_visibleTilesOnScreen.height - 1) * gridSize.height));

	[self createTilesetBatchNodes];
	
	// force initial draw
	_tilemap.modified = YES;
}

-(void) createTilesetBatchNodes
{
	_batchNode = [SKNode node];
	_batchNode.zPosition = 1;
	[self addChild:_batchNode];

	// get all tileset textures and create batch nodes, but don't add them as child just yet
	for (KKTilemapTileset* tileset in _tilemap.tilesets)
	{
		// load and setup textures
		[tileset texture];
	}
	
	// initialize sprites with dummy textures
	NSUInteger bufferSize = sizeof(SKSpriteNode*) * _visibleTilesOnScreen.width * _visibleTilesOnScreen.height;
	_visibleTiles = (void**)malloc(bufferSize);

	NSUInteger i = 0;
	SKSpriteNode* tileSprite = nil;
	for (int tilePosY = 0; tilePosY < _visibleTilesOnScreen.height; tilePosY++)
	{
		for (int tilePosX = 0; tilePosX < _visibleTilesOnScreen.width; tilePosX++)
		{
			tileSprite = [SKSpriteNode node];
			tileSprite.size = CGSizeMake(_tilemap.gridSize.width, _tilemap.gridSize.height);
			//tileSprite.hidden = YES;
			tileSprite.anchorPoint = CGPointZero;
			[_batchNode addChild:tileSprite];
			
			_visibleTiles[i++] = (__bridge void*)tileSprite;
		}
	}
	
	_visibleTilesCount = i;
}

-(void) willMoveFromParent
{
	free(_visibleTiles);
	_visibleTiles = nil;
	_visibleTilesCount = 0;
}

-(void) setPosition:(CGPoint)position
{
	// prevent flicker, particularly when tilesets have no spacing between tiles
	// does allow .5 coords for pixel-precision positioning on Retina devices
	position.x = (int)(position.x * 2.0) / 2.0;
	position.y = (int)(position.y * 2.0) / 2.0;
	[super setPosition:position];
}

-(void) updateLayer
{
	self.hidden = _layer.hidden;
	
	if (self.hidden == NO && (CGPointEqualToPoint(self.position, _previousPosition) == NO || _tilemap.modified))
	{
		// Rendering is split into top and bottom half rows to utilize dual-core CPUs.
		// All iOS 7 devices except iPhone 4 have dual-core CPUs.
		
		NSUInteger halfHeight = _visibleTilesOnScreen.height / 2.0;
		//[self renderLinesFrom:0 to:halfHeight];
		//[self renderLinesFrom:halfHeight to:_visibleTilesOnScreen.height];

		dispatch_queue_t tileRenderQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
		dispatch_group_t tileRenderGroup = dispatch_group_create();
		
		dispatch_group_async(tileRenderGroup, tileRenderQueue, ^{
			[self renderLinesFrom:0 to:halfHeight];
		});
		dispatch_group_async(tileRenderGroup, tileRenderQueue, ^{
			[self renderLinesFrom:halfHeight to:_visibleTilesOnScreen.height];
		});
		
		dispatch_group_wait(tileRenderGroup, DISPATCH_TIME_FOREVER);
	}
	
	_previousPosition = self.position;
}

-(void) renderLinesFrom:(NSUInteger)fromLine to:(NSUInteger)toLine
{
	// create initial tiles to fill screen
	CGSize mapSize = _tilemap.size;
	CGSize gridSize = _tilemap.gridSize;
	
	CGPoint tilemapOffset = ccpSub(self.scene.frame.origin, self.parent.position);
	CGPoint positionInPoints = ccpMult(ccpSub(self.position, tilemapOffset), -1.0f);

	// fast-forward position by one tile width/height in negative direction
	// reason: 1 and -1 would use the same tile due to the division in tileOffset calculation (tilesize 40: position 39 and -39 would both index tile 0)
	if (positionInPoints.x < 0.0f)
	{
		positionInPoints.x -= gridSize.width;
	}
	if (positionInPoints.y < 0.0f)
	{
		positionInPoints.y -= gridSize.height;
	}
	
	CGPoint offsetInTiles = CGPointMake((int32_t)(positionInPoints.x / gridSize.width), (int32_t)(positionInPoints.y / gridSize.height));
	CGPoint offsetInPoints = CGPointMake(offsetInTiles.x * gridSize.width, offsetInTiles.y * gridSize.height);
	
	NSUInteger i = fromLine * _visibleTilesOnScreen.width;
	SKSpriteNode* tileSprite = nil;
	KKTilemapTileset* currentTileset = nil;
	KKTilemapTileset* previousTileset = nil;
	NSUInteger layerGidCount = _layer.tileCount;
	gid_t* layerGids = _layer.tiles.gid;
	BOOL endlessScrollingHorizontal = _layer.endlessScrollingHorizontal;
	BOOL endlessScrollingVertical = _layer.endlessScrollingVertical;

	for (NSUInteger viewTilePosY = fromLine; viewTilePosY < toLine; viewTilePosY++)
	{
		for (NSUInteger viewTilePosX = 0; viewTilePosX < _visibleTilesOnScreen.width; viewTilePosX++)
		{
			NSAssert2(_visibleTilesCount >= i,
					  @"Tile layer index (%u) out of bounds (%u)! Perhaps due to window resize?",
					  (unsigned int)i, (unsigned int)_visibleTilesCount);
			
			// get the proper git coordinate, wrap around as needed
			CGPoint gidCoordInLayer = CGPointMake(viewTilePosX + offsetInTiles.x,
												  mapSize.height - 1 - viewTilePosY - offsetInTiles.y);
			
			if (endlessScrollingHorizontal)
			{
				// adjust the tile coord to be within bounds of the map when endless scrolling is enabled
				gidCoordInLayer.x = (NSInteger)gidCoordInLayer.x % (NSInteger)mapSize.width;
				
				// ensure positive coords
				if (gidCoordInLayer.x < 0.0f)
				{
					gidCoordInLayer.x += mapSize.width;
				}
			}
			
			if (endlessScrollingVertical)
			{
				// adjust the tile coord to be within bounds of the map when endless scrolling is enabled
				gidCoordInLayer.y = (NSInteger)gidCoordInLayer.y % (NSInteger)mapSize.height;
				
				// ensure positive coords
				if (gidCoordInLayer.y < 0.0f)
				{
					gidCoordInLayer.y += mapSize.height;
				}
			}

			// calculate the gid index and verify it
			NSUInteger gidIndex = (NSUInteger)(gidCoordInLayer.x + gidCoordInLayer.y * mapSize.width);
			if (gidIndex >= layerGidCount)
			{
				continue;
			}
			
			// get the gid for the coordinate
			gid_t gid = layerGids[gidIndex];
			
			// no tile at this coordinate? If so, skip drawing this tile.
			if ((gid & KKTilemapTileFlipMask) == 0)
			{
				continue;
			}
			
			/*
			 // draw tile coords if enabled, only every second column (to avoid overlap)
			 if (_drawTileCoordinates && ((int)gidCoordInLayer.x % 2 == 0))
			 {
			 CCLabelAtlas* label = [_coordLabels objectAtIndex:i - 1]; // minus 1, i was already increased above
			 [label setString:[NSString stringWithFormat:@"%i/%i", (int)gidCoordInLayer.x, (int)gidCoordInLayer.y]];
			 label.position = ccpAdd(tileSpritePosition, ccp(0, gridSize.height * 0.4f));
			 label.visible = YES;
			 }
			 */
			
			// update position
			CGPoint tileSpritePosition = CGPointMake(viewTilePosX * gridSize.width + offsetInPoints.x,
													 viewTilePosY * gridSize.height + offsetInPoints.y);
			
			// set flip & rotation defaults
			CGFloat zRotation = 0.0, xScale = 1.0, yScale = 1.0;
			const CGFloat k270DegreesRadians = M_PI_2 * 3.0;
			if (gid & KKTilemapTileDiagonalFlip)
			{
				// handle the diagonally flipped states.
				gid_t gidFlipFlags = gid & (KKTilemapTileHorizontalFlip | KKTilemapTileVerticalFlip);
				if (gidFlipFlags == 0)
				{
					zRotation = M_PI_2; // 90°
					xScale = -1.0;
					tileSpritePosition.x += gridSize.width;
					tileSpritePosition.y += gridSize.height;
				}
				else if (gidFlipFlags == KKTilemapTileHorizontalFlip)
				{
					zRotation = k270DegreesRadians;
					tileSpritePosition.y += gridSize.height;
				}
				else if (gidFlipFlags == KKTilemapTileVerticalFlip)
				{
					zRotation = M_PI_2; // 90°
					tileSpritePosition.x += gridSize.width;
				}
			}
			else
			{
				if ((gid & KKTilemapTileHorizontalFlip) == KKTilemapTileHorizontalFlip)
				{
					xScale = -1.0;
					tileSpritePosition.x += gridSize.width;
				}
				if ((gid & KKTilemapTileVerticalFlip) == KKTilemapTileVerticalFlip)
				{
					yScale = -1.0;
					tileSpritePosition.y += gridSize.height;
				}
			}

			tileSprite = (__bridge SKSpriteNode*)_visibleTiles[i++];
			tileSprite.zRotation = zRotation;
			tileSprite.xScale = xScale;
			tileSprite.yScale = yScale;
			tileSprite.position = tileSpritePosition;
			tileSprite.hidden = NO;
			
			// get the gid's tileset, reuse previous tileset if possible
			currentTileset = previousTileset;
			if (gid < currentTileset.firstGid || gid > currentTileset.lastGid || currentTileset == nil)
			{
				currentTileset = [_tilemap tilesetForGid:gid];
				NSAssert1(currentTileset, @"Invalid gid: no tileset found for gid %u!", (gid & KKTilemapTileFlipMask));
			}
			
			SKTexture* tileSpriteTexture = [currentTileset textureForGid:gid];
			NSAssert1(tileSpriteTexture, @"tilesprite texture is nil for gid: %u", gid);
			
			// saves a little bit performance to make the assignment only when necessary
			if (tileSprite.texture != tileSpriteTexture)
			{
				tileSprite.texture = tileSpriteTexture;
			}
			
			previousTileset = currentTileset;
		}
	}
	
	// hide the remaining sprites
	NSUInteger remainingTilesCount = toLine * _visibleTilesOnScreen.width;
	for (NSUInteger k = i; k < remainingTilesCount; k++)
	{
		[(__bridge SKSpriteNode*)_visibleTiles[k] setHidden:YES];
	}
}

@end
