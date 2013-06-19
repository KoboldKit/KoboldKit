//
//  KKTilemapNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "KKNode.h"

@class KKTilemap;
@class KKTilemapTileLayerNode;

/** A tilemap node renders a TMX tilemap. It has KKTilemapTileLayerNode and KKTilempaObjectLayerNode as children
 which perform each layer's rendering. */
@interface KKTilemapNode : KKNode
{
	@private
	__weak KKTilemapTileLayerNode* _mainTileLayerNode;
	NSMutableArray* _tileLayers;
}

/** Returns the tilemap model object containing the tilemap's data. */
@property (atomic) KKTilemap* tilemap;

/** Returns the "main" tile layer node. The main layer in a parallaxing tilemap is the layer with a parallax ratio of 1.0f. */
@property (nonatomic, readonly) KKTilemapTileLayerNode* mainTileLayerNode;

/** Creates a tilemap node from a TMX file. */
+(id) tilemapWithContentsOfFile:(NSString*)tmxFile;

@end
