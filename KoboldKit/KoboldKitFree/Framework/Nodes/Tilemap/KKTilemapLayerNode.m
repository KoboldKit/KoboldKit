/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTilemapLayerNode.h"
#import "KKMacros.h"
#import "KKTilemapLayer.h"
#import "KKTilemap.h"

@implementation KKTilemapLayerNode

-(id) initWithLayer:(KKTilemapLayer*)layer
{
	self = [super init];
	if (self)
	{
		_layer = layer;
		_tilemap = _layer.tilemap;
		self.name = layer.name;
	}
	return self;
}

-(CGPoint) tileCoordForPoint:(CGPoint)point
{
	return [self tileCoordForPoint:point wrapToMapSize:NO];
}

-(CGPoint) tileCoordForPoint:(CGPoint)point wrapToMapSize:(BOOL)wrapToMapSize
{
	KKTilemap* tilemap = self.layer.tilemap;
	CGSize gridSize = tilemap.gridSize;
	CGSize mapSize = tilemap.size;

	// fast-forward position by one tile when point is negative
	// reason: division would cause the -1,-1 coordinates as still being 0,0
	if (point.x < 0.0f)
	{
		point.x -= gridSize.width;
	}
	
	if (point.y < 0.0f)
	{
		point.y -= gridSize.height;
	}
	
	CGPoint tileCoord = CGPointZero;
	switch (tilemap.orientation)
	{
		case KKTilemapOrientationOrthogonal:
			tileCoord = CGPointMake((int)(point.x / gridSize.width), mapSize.height - 1 - (int)(point.y / gridSize.height));
			if (wrapToMapSize)
			{
				tileCoord = CGPointMake((int)tileCoord.x % (int)mapSize.width, (int)tileCoord.y % (int)mapSize.height);
				
				// ensure coords are positive
				if (tileCoord.x < 0.0f)
				{
					tileCoord.x += mapSize.width;
				}
				
				if (tileCoord.y < 0.0f)
				{
					tileCoord.y += mapSize.height;
				}
			}
			
			break;
			
		default:
			[NSException raise:@"tileCoordFromPoint: unsupported orientation"
			            format:@"currently no coordinate conversion supported for orientation %i - please report.", tilemap.orientation];
			break;
	}
	
	return tileCoord;
}

-(CGPoint) centerPositionForTileCoord:(CGPoint)tileCoord
{
	CGPoint point = [self positionForTileCoord:tileCoord];
	CGSize gridSize = _tilemap.gridSize;
	return ccpAdd(point, CGPointMake(gridSize.width * 0.5f, gridSize.height * 0.5f));
}

-(CGPoint) positionForTileCoord:(CGPoint)tileCoord
{
	CGPoint point = CGPointZero;
	CGSize gridSize = _tilemap.gridSize;
	CGSize mapSize = _tilemap.size;
	
	switch (_tilemap.orientation)
	{
		case KKTilemapOrientationOrthogonal:
			point = CGPointMake(tileCoord.x * gridSize.width, (mapSize.height - 1) * gridSize.height - (tileCoord.y * gridSize.height));
			break;
			
		default:
			[NSException raise:@"tileCoordFromPoint: unsupported orientation"
			            format:@"currently no support for coordinate conversion for orientation %i - please report.", _tilemap.orientation];
			break;
	}
	
	return point;
}

@end
