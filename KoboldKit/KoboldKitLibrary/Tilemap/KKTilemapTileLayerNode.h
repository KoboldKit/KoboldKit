//
//  KKTilemapTileLayerNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKTilemapLayerNode.h"

@class KKTilemap;
@class KKTilemapLayer;

/** Tile layer node renders a TMX tile layer. */
@interface KKTilemapTileLayerNode : KKTilemapLayerNode
{
	@private
	__weak KKTilemap* _tilemap;
	__weak KKTilemapLayer* _layer;
	NSMutableDictionary* _batchNodes;
	NSMutableArray* _visibleTiles;
	CGSize _visibleTilesOnScreen;
	CGSize _viewBoundary;
	CGPoint _previousPosition;
}

@property (atomic, readonly, weak) KKTilemapLayer* layer;

+(id) tileLayerWithLayer:(KKTilemapLayer*)layer;

/** Updates the layer's tile sprites based on position, scale and view size. */
-(void) updateLayer;

@end
