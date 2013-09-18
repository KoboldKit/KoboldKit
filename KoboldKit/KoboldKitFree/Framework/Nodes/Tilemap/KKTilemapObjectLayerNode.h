/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTilemapLayerNode.h"

@class KKTilemap;
@class KKTilemapLayer;

/** Object layer node renders Tiled objects. */
@interface KKTilemapObjectLayerNode : KKTilemapLayerNode

/** @param layer A tilemap object layer.
 @returns A new instance. */
+(id) objectLayerNodeWithLayer:(KKTilemapLayer*)layer;

@end
