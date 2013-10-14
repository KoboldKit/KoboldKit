/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


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
	
	_visibleTilesOnScreen = CGSizeMake(ceil(sceneSize.width / gridSize.width) + 2, ceil(sceneSize.height / gridSize.height) + 2);
	_viewBoundary = CGSizeMake(-(mapSize.width * gridSize.width - (_visibleTilesOnScreen.width - 1) * gridSize.width),
							   -(mapSize.height * gridSize.height - (_visibleTilesOnScreen.height - 1) * gridSize.height));

	[self createTilesetBatchNodes];
	
	// force initial draw
	_tilemap.modified = YES;
}

-(void) createTilesetBatchNodes
{
	_doNotRenderTiles = [[_layer.properties.properties objectForKey:@"doNotRenderTiles"] boolValue];
	
	if (_doNotRenderTiles == NO)
	{
		_batchNode = [SKNode node];
		_batchNode.zPosition = -1;
		[self addChild:_batchNode];
		
		// get all tileset textures and create batch nodes, but don't add them as child just yet
		for (KKTilemapTileset* tileset in _tilemap.tilesets)
		{
			// load and setup textures
			[tileset texture];
		}
		
		// initialize sprites with dummy textures
		NSUInteger bufferSize = sizeof(SKSpriteNode*) * _visibleTilesOnScreen.width * _visibleTilesOnScreen.height;
		_visibleTileSprites = (void**)malloc(bufferSize);
		
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
				
				_visibleTileSprites[i++] = (__bridge void*)tileSprite;
			}
		}
		
		_visibleTileSpritesCount = i;
	}
}

-(void) willMoveFromParent
{
	free(_visibleTileSprites);
	_visibleTileSprites = nil;
	_visibleTileSpritesCount = 0;
}

-(void) setPosition:(CGPoint)position
{
	// prevent flicker, particularly when tilesets have no spacing between tiles
	// does allow .5 coords for pixel-precision positioning on Retina devices
	position.x = round(position.x * 2.0) / 2.0;
	position.y = round(position.y * 2.0) / 2.0;
	[super setPosition:position];
}

-(void) updateLayer
{
	self.hidden = _layer.hidden;
	
	// only update tile sprites when needed
	if (_doNotRenderTiles == NO && self.hidden == NO &&
		(CGPointEqualToPoint(self.position, _previousPosition) == NO || _tilemap.modified))
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
		
		NSUInteger i = 0;
		SKSpriteNode* tileSprite = nil;
		KKTilemapTileset* currentTileset = nil;
		KKTilemapTileset* previousTileset = nil;
		
		for (int viewTilePosY = 0; viewTilePosY < _visibleTilesOnScreen.height; viewTilePosY++)
		{
			for (int viewTilePosX = 0; viewTilePosX < _visibleTilesOnScreen.width; viewTilePosX++)
			{
				NSAssert2(_visibleTileSpritesCount > i,
						  @"Tile layer index (%u) out of bounds (%u)! Perhaps due to window resize?",
						  (unsigned int)i, (unsigned int)_visibleTileSpritesCount);
				
				tileSprite = (__bridge SKSpriteNode*)_visibleTileSprites[i++];
				
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
				if (currentTileset == nil || gid < currentTileset.firstGid || gid > currentTileset.lastGid)
				{
					currentTileset = [_tilemap tilesetForGid:gid];
					NSAssert1(currentTileset, @"Invalid gid: no tileset found for gid %u!", (gid & KKTilemapTileFlipMask));
				}
				
				// switch the batch node if the current gid uses a different tileset than the previous gid
				if (currentTileset != previousTileset)
				{
					previousTileset = currentTileset;
				}
				
				tileSprite.texture = [currentTileset textureForGid:gid];
				NSAssert1(tileSprite.texture, @"tilesprite texture is nil for gid: %u", gid);
				
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
			}
		}
	}
	
	_previousPosition = self.position;
}

@end
