//
//  KKTilemapObjectLayerNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKTilemapLayerNode.h"

@class KKTilemap;
@class KKTilemapLayer;

/** Object layer node renders Tiled objects. */
@interface KKTilemapObjectLayerNode : KKTilemapLayerNode

/** @param layer A tilemap object layer.
 @returns A new instance. */
+(id) objectLayerNodeWithLayer:(KKTilemapLayer*)layer;

@end
