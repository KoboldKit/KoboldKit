//
//  KKTilemapLayerNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKCompatibility.h"
#import "KKNode.h"

@class KKTilemap;
@class KKTilemapLayer;

/** (not documented) may be removed */
@interface KKTilemapLayerNode : KKNode
{
	@protected
	__weak KKTilemap* _tilemap;
	__weak KKTilemapLayer* _layer;
}

/** @returns The tilemap layer object. */
@property (atomic, readonly, weak) KKTilemapLayer* layer;

@end
