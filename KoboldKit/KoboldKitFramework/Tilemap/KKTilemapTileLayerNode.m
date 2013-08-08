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
#import "SKNode+KoboldKit.h"
#import "KKScene.h"
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
	//NSUInteger numTilesets = _tilemap.tilesets.count;
	//_batchNodes = [NSMutableDictionary dictionaryWithCapacity:numTilesets];
	
	_batchNode = [SKNode node];
	_batchNode.zPosition = 1;
	[self addChild:_batchNode];

	// get all tileset textures and create batch nodes, but don't add them as child just yet
	for (KKTilemapTileset* tileset in _tilemap.tilesets)
	{
		/*
		SKNode* batchNode = [SKNode node];
		batchNode.zPosition = 1;
		[_batchNodes setObject:batchNode forKey:tileset.imageFile];
		 */
		
		// load and setup textures
		[tileset texture];
	}
	
	// initialize sprites with dummy textures
	//_visibleTiles = [NSMutableArray arrayWithCapacity:_visibleTilesOnScreen.width * _visibleTilesOnScreen.height];
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
			tileSprite.hidden = YES;
			tileSprite.anchorPoint = CGPointZero;
			[_batchNode addChild:tileSprite];
			
			//[_visibleTiles addObject:tileSprite];
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
	
	//if (self.hidden == NO && (CGPointEqualToPoint(self.position, _previousPosition) == NO || _tilemap.modified))
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
		
		//SKSpriteNode* nextTileSprite = (__bridge SKSpriteNode*)_visibleTiles[i++];

		//SKNode* currentBatchNode = nil;
		//NSUInteger countBatchNodeReparenting = 0;
		
		//dispatch_queue_t fetchTileQueue = dispatch_queue_create("fetchTileQueue", DISPATCH_QUEUE_CONCURRENT);
		dispatch_group_t renderGroup = dispatch_group_create();
		dispatch_queue_t highPriorityQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
		
		//dispatch_async(fetchTileQueue, ^{
		for (int viewTilePosY = 0; viewTilePosY < _visibleTilesOnScreen.height; viewTilePosY++)
		{
			dispatch_group_async(renderGroup, highPriorityQueue, ^{
				SKSpriteNode* tileSprite = nil;
				NSUInteger i = viewTilePosY * _visibleTilesOnScreen.height;
				KKTilemapTileset* currentTileset = nil;
				KKTilemapTileset* previousTileset = nil;
				
			for (int viewTilePosX = 0; viewTilePosX < _visibleTilesOnScreen.width; viewTilePosX++)
			{
				/*
				NSAssert2(_visibleTiles.count > i,
						  @"Tile layer index (%u) out of bounds (%u)! Perhaps due to window resize?",
						  (unsigned int)i, (unsigned int)_visibleTiles.count);
				
				tileSprite = [_visibleTiles objectAtIndex:i++];
				 */
				
				NSAssert2(_visibleTilesCount >= i,
						  @"Tile layer index (%u) out of bounds (%u)! Perhaps due to window resize?",
						  (unsigned int)i, (unsigned int)_visibleTilesCount);
				
				tileSprite = (__bridge SKSpriteNode*)_visibleTiles[i++];
				/*
				dispatch_async(fetchTileQueue, ^{
					if (i < _visibleTilesCount)
					{
						nextTileSprite = (__bridge SKSpriteNode*)_visibleTiles[i++];
					}
				});
				*/
				
				// get the proper git coordinate, wrap around as needed
				CGPoint gidCoordInLayer = CGPointMake(viewTilePosX + offsetInTiles.x, (mapSize.height - 1 - viewTilePosY) - offsetInTiles.y);
				gid_t gid = [_layer tileGidWithFlagsAt:gidCoordInLayer];

				// no tile at this coordinate? If so, skip drawing this tile.
				if ((gid & KKTilemapTileFlipMask) == 0)
				{
					tileSprite.hidden = YES;
					continue;
				}

				tileSprite.hidden = NO;

				// get the gid's tileset, reuse previous tileset if possible
				currentTileset = previousTileset;
				if (gid < currentTileset.firstGid || gid > currentTileset.lastGid || currentTileset == nil)
				{
					currentTileset = [_tilemap tilesetForGid:gid];
					NSAssert1(currentTileset, @"Invalid gid: no tileset found for gid %u!", (gid & KKTilemapTileFlipMask));
				}
				
				/*
				// switch the batch node if the current gid uses a different tileset than the previous gid
				if (currentTileset != previousTileset)
				{
					previousTileset = currentTileset;
					
					currentBatchNode = [_batchNodes objectForKey:currentTileset.imageFile];
					NSAssert1(currentBatchNode, @"batch node not found for key: %@", currentTileset.imageFile);
				}
				 */

				// saves a little bit performance to make the assignment only when necessary
				SKTexture* tileSpriteTexture = [currentTileset textureForGid:gid];
				NSAssert1(tileSpriteTexture, @"tilesprite texture is nil for gid: %u", gid);
				if (tileSprite.texture != tileSpriteTexture)
				{
					tileSprite.texture = tileSpriteTexture;
				}
		
				/*
				// change the tile sprite's batch node since we're switching tilesets
				if (tileSprite.parent != currentBatchNode)
				{
					countBatchNodeReparenting++;
					[tileSprite removeFromParent];
					[currentBatchNode addChild:tileSprite];
					
					// if this batchnode has no parent, it needs to be added as child (happens on first use)
					if (currentBatchNode.parent == nil)
					{
						[self addChild:currentBatchNode];
					}
				}
				 */
				
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
				
				tileSprite.zRotation = zRotation;
				tileSprite.xScale = xScale;
				tileSprite.yScale = yScale;
				tileSprite.position = tileSpritePosition;
				
				previousTileset = currentTileset;
			}
				
			});

		}
		
		/*
		if (countBatchNodeReparenting > 0)
		{
			LOG_EXPR(countBatchNodeReparenting);
		}
		 */

		dispatch_group_wait(renderGroup, DISPATCH_TIME_FOREVER);
	}
	
	_previousPosition = self.position;
}

@end
