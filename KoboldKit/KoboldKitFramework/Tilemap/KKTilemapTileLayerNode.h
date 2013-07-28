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
	NSMutableDictionary* _batchNodes;
	NSMutableArray* _visibleTiles;
	CGSize _visibleTilesOnScreen;
	CGSize _viewBoundary;
	CGPoint _previousPosition;
}

/** @param layer The tilemap layer object.
 @returns A new instance. */
+(id) tileLayerNodeWithLayer:(KKTilemapLayer*)layer;

/** Updates the layer's tile sprites based on position, scale and view size. */
-(void) updateLayer;

@end
