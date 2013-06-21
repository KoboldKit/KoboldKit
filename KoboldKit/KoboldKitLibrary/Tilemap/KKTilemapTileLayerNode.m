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

+(id) tileLayerWithLayer:(KKTilemapLayer*)layer
{
	return [[self alloc] initWithLayer:layer];
}

-(id) initWithLayer:(KKTilemapLayer*)layer
{
	self = [super init];
	if (self)
	{
		_layer = layer;
		_tilemap = _layer.tilemap;
	}
	return self;
}

-(void) didMoveToParent
{
	NSLog(@"Tile layer: %@", _layer.name);
	
	CGSize sceneSize = self.scene.size;
	CGSize gridSize = _tilemap.gridSize;
	CGSize mapSize = _tilemap.mapSize;
	
	_visibleTilesOnScreen = CGSizeMake(sceneSize.width / gridSize.width + 1, sceneSize.height / gridSize.height + 1);
	_viewBoundary = CGSizeMake(-(mapSize.width * gridSize.width - (_visibleTilesOnScreen.width - 1) * gridSize.width),
							   -(mapSize.height * gridSize.height - (_visibleTilesOnScreen.height - 1) * gridSize.height));

	if (_batchNodes == nil)
	{
		[self createTilesetBatchNodes];
	}
	
	// make sure previous position does not match current to force first-time draw
	_previousPosition = CGPointMake(INT64_MAX, INT64_MIN);
}

-(void) createTilesetBatchNodes
{
	NSUInteger numTilesets = _tilemap.tilesets.count;
	_batchNodes = [NSMutableDictionary dictionaryWithCapacity:numTilesets];

	// get all tileset textures and create batch nodes, but don't add them as child just yet
	for (KKTilemapTileset* tileset in _tilemap.tilesets)
	{
		KKNode* batchNode = [KKNode node];
		batchNode.zPosition = -1;
		[_batchNodes setObject:batchNode forKey:tileset.imageFile];
		
		// load and setup textures
		[tileset texture];
	}
	
	// initialize sprites with dummy textures
	_visibleTiles = [NSMutableArray arrayWithCapacity:_visibleTilesOnScreen.width * _visibleTilesOnScreen.height];
	KKSpriteNode* tileSprite = nil;
	for (int tilePosY = 0; tilePosY < _visibleTilesOnScreen.height; tilePosY++)
	{
		for (int tilePosX = 0; tilePosX < _visibleTilesOnScreen.width; tilePosX++)
		{
			tileSprite = [KKSpriteNode node];
			tileSprite.size = CGSizeMake(_tilemap.gridSize.width, _tilemap.gridSize.height);
			tileSprite.hidden = YES;
			tileSprite.anchorPoint = CGPointZero;
			[_visibleTiles addObject:tileSprite];
			
			// FIXME: for whatever reasons tile sprites won't draw in batch nodes when not added immediately
			//[self addChild:tileSprite];
		}
	}
}

-(void) updateLayer
{
	self.hidden = _layer.hidden;
	
	if (CGPointEqualToPoint(self.position, _previousPosition) == NO || _tilemap.modified)
	{
		// create initial tiles to fill screen
		CGSize mapSize = _tilemap.mapSize;
		CGSize gridSize = _tilemap.gridSize;
		
		CGPoint positionInPoints = ccpMult(self.position, -1.0f);
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
		
		NSUInteger i = 0;
		KKSpriteNode* tileSprite = nil;
		KKNode* currentBatchNode = nil;
		KKTilemapTileset* previousTileset = nil;
		NSUInteger countBatchNodeReparenting = 0;
		
#pragma message "Re-implement endless scrolling (wrap-around)"
		//BOOL endlessScrollingHorizontal = _tileLayer.endlessScrollingHorizontal;
		//BOOL endlessScrollingVertical = _tileLayer.endlessScrollingVertical;
		
		for (int viewTilePosY = 0; viewTilePosY < _visibleTilesOnScreen.height; viewTilePosY++)
		{
			for (int viewTilePosX = 0; viewTilePosX < _visibleTilesOnScreen.width; viewTilePosX++)
			{
				NSAssert2(_visibleTiles.count > i,
						  @"Tile layer index (%u) out of bounds (%u)! Perhaps due to window resize?",
						  (unsigned int)i, (unsigned int)_visibleTiles.count);
				
				tileSprite = [_visibleTiles objectAtIndex:i++];
				
				// get the proper git coordinate, wrap around as needed
				CGPoint gidCoordInLayer = CGPointMake(viewTilePosX + offsetInTiles.x, (mapSize.height - 1 - viewTilePosY) - offsetInTiles.y);
				
				/*
				if (endlessScrollingHorizontal)
				{
					// fix coordinates for endless scrolling as coords need to be wrapped to be in bounds of the map
					gidCoordInLayer.x = (int)gidCoordInLayer.x % (int)mapSize.width;
					
					// ensure positive coordinates
					if (gidCoordInLayer.x < 0.0f)
					{
						gidCoordInLayer.x += mapSize.width;
					}
				}
				
				if (endlessScrollingVertical)
				{
					// fix coordinates for endless scrolling as coords need to be wrapped to be in bounds of the map
					gidCoordInLayer.y = (int)gidCoordInLayer.y % (int)mapSize.height;
					
					// ensure positive coordinates
					if (gidCoordInLayer.y < 0.0f)
					{
						gidCoordInLayer.y += mapSize.height;
					}
				}
				 */
				
				// no tile at this coordinate?
				gid_t gid = [_layer tileGidWithFlagsAt:gidCoordInLayer];
				if ((gid & KKTilemapTileFlipMask) == 0)
				{
					tileSprite.hidden = YES;
					continue;
				}

				tileSprite.hidden = NO;

				// get the gid's tileset, reuse previous tileset if possible
				KKTilemapTileset* currentTileset = previousTileset;
				if (currentTileset == nil || gid < currentTileset.firstGid || gid > currentTileset.lastGid)
				{
					currentTileset = [_tilemap tilesetForGid:gid];
					NSAssert1(currentTileset, @"Invalid gid: no tileset found for gid %u!", (gid & KKTilemapTileFlipMask));
				}
				
				// switch the batch node if the current gid uses a different tileset than the previous gid
				if (currentTileset != previousTileset)
				{
					previousTileset = currentTileset;
					currentBatchNode = [_batchNodes objectForKey:currentTileset.imageFile];
					NSAssert1(currentBatchNode, @"batch node not found for key: %@", currentTileset.imageFile);
				}

				tileSprite.texture = [currentTileset textureForGid:gid];
				NSAssert1(tileSprite.texture, @"tilesprite texture is nil for gid: %u", gid);
				
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
				// set flip defaults
				tileSprite.zRotation = 0.0;
				tileSprite.xScale = 1.0;
				tileSprite.yScale = 1.0;
				
				const CGFloat k270DegreesRadians = M_PI_2 * 3.0;
				if (gid & KKTilemapTileDiagonalFlip)
				{
					// handle the diagonally flipped states.
					gid_t gidFlipFlags = gid & (KKTilemapTileHorizontalFlip | KKTilemapTileVerticalFlip);
					if (gidFlipFlags == 0)
					{
						tileSprite.zRotation = M_PI_2; // 90°
						tileSprite.xScale = -1.0;
						tileSpritePosition.x += gridSize.width;
						tileSpritePosition.y += gridSize.height;
					}
					else if (gidFlipFlags == KKTilemapTileHorizontalFlip)
					{
						tileSprite.zRotation = k270DegreesRadians;
						tileSpritePosition.y += gridSize.height;
					}
					else if (gidFlipFlags == KKTilemapTileVerticalFlip)
					{
						tileSprite.zRotation = M_PI_2; // 90°
						tileSpritePosition.x += gridSize.width;
					}
				}
				else
				{
					if ((gid & KKTilemapTileHorizontalFlip) == KKTilemapTileHorizontalFlip)
					{
						tileSprite.xScale = -1.0;
						tileSpritePosition.x += gridSize.width;
					}
					if ((gid & KKTilemapTileVerticalFlip) == KKTilemapTileVerticalFlip)
					{
						tileSprite.yScale = -1.0;
						tileSpritePosition.y += gridSize.height;
					}
				}
				
				tileSprite.position = tileSpritePosition;
			}
		}
		
		/*
		if (countBatchNodeReparenting > 0)
		{
			LOG_EXPR(countBatchNodeReparenting);
		}
		 */
	}
	
	_previousPosition = self.position;
}

@end
