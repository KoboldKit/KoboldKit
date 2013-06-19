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

@interface KKTilemapObjectLayerNode : KKTilemapLayerNode
{
@protected
	__weak KKTilemap* _tilemap;
	__weak KKTilemapLayer* _layer;
	
@private
}

+(id) objectLayerWithLayer:(KKTilemapLayer*)layer tilemap:(KKTilemap*)tilemap;

@end
