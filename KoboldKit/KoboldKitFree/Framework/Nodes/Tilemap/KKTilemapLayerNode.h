/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"
#import "KKNode.h"

@class KKTilemap;
@class KKTilemapLayer;
@class KKTilemapNode;

/** Common base class for both KKTilemapObjectLayerNode and KKTilemapTileLayerNode */
@interface KKTilemapLayerNode : KKNode
{
	@protected
	__weak KKTilemap* _tilemap;
	__weak KKTilemapLayer* _layer;
}

/** @returns The tilemap layer object. */
@property (atomic, readonly, weak) KKTilemapLayer* layer;

/** @returns The layer's tilemap node. */
@property (atomic, weak) KKTilemapNode* tilemapNode;

/** Converts a point from scene coordinates to tile coordinates within the layer. */
-(CGPoint) tileCoordForPoint:(CGPoint)point;

/** nd */
-(CGPoint) centerPositionForTileCoord:(CGPoint)tileCoord;
/** nd */
-(CGPoint) positionForTileCoord:(CGPoint)tileCoord;

@end
