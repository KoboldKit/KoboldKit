/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTilemapLayerNode.h"

@class KKTilemap;
@class KKTilemapLayer;

/** Tile layer node renders a TMX tile layer. */
@interface KKTilemapTileLayerNode : KKTilemapLayerNode
{
	@private
	SKNode* _batchNode;
	
	void** _visibleTileSprites;
	NSUInteger _visibleTileSpritesCount;
	
	CGSize _visibleTilesOnScreen;
	CGSize _viewBoundary;
	CGPoint _previousPosition;
	BOOL _doNotRenderTiles;
}

/** @param layer The tilemap layer object.
 @returns A new instance. */
+(id) tileLayerNodeWithLayer:(KKTilemapLayer*)layer;

/** Updates the layer's tile sprites based on position, scale and view size. */
-(void) updateLayer;

@end
