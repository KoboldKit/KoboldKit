//
//  KKTilemapNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKCompatibility.h"
#import "KKNode.h"

@class KKTilemap;
@class KKTilemapTileLayerNode;
@class KKTilemapObjectLayerNode;
@class KKIntegerArray;

/** A tilemap node renders a TMX tilemap. It has KKTilemapTileLayerNode and KKTilempaObjectLayerNode as children
 which perform each layer's rendering. */
@interface KKTilemapNode : KKNode
{
	@private
	NSMutableArray* _tileLayerNodes;
	NSMutableArray* _objectLayerNodes;
}

/** @returns the tilemap model object containing the tilemap's data.*/
@property (atomic) KKTilemap* tilemap;

/** @returns The tilemap's bounds rect in points. The x/width and/or y/height are set to INFINITY if the main layer is set to endless scrolling
 (horizontal or vertical). */
@property (atomic, readonly) CGRect bounds;

/** The main layer in a parallaxing tilemap is the layer with a parallax ratio of 1.0f. Otherwise it's the first tile layer.
 @returns the "main" tile layer node.  */
@property (atomic, weak, readonly) KKTilemapTileLayerNode* mainTileLayerNode;

/** The game object layer is the object layer where (most) game objects reside. Usually the layer that scrolls parallel to the main tile layer.
 @returns the "game objects" object layer node.  */
@property (atomic, weak, readonly) KKTilemapObjectLayerNode* gameObjectsLayerNode;

/** Creates a tilemap node from a TMX file.
 @param tmxFile The filename of a TMX file in the bundle or an absolute path to a TMX file. 
 @returns The new instance. */
+(id) tilemapWithContentsOfFile:(NSString*)tmxFile;

/** @param name The name identifying a tile layer.
 @returns The tile layer node with the name, or nil if there's no tile layer with that name. */
-(KKTilemapTileLayerNode*) tileLayerNodeNamed:(NSString*)name;

/** @param name The name identifying an object layer.
 @returns The object layer node with the name, or nil if there's no object layer with that name. */
-(KKTilemapObjectLayerNode*) objectLayerNodeNamed:(NSString*)name;

/** Creates physics blocking shapes from the main tile layer's blocking tiles and the blockingTiles or nonBlockingTiles properties of tilesets.
 @param tileLayerNode The tile layer node for which to create physics shapes.
 @returns The node containing child nodes for each physics body created. */
-(SKNode*) createPhysicsShapesWithTileLayerNode:(KKTilemapTileLayerNode*)tileLayerNode;

/** Creates physics blocking shapes from an object layer's objects.
 @param objectLayerNode The object layer node from whose objects to create physics shapes.
 @returns The node containing child nodes for each physics body created. */
-(SKNode*) createPhysicsShapesWithObjectLayerNode:(KKTilemapObjectLayerNode*)objectLayerNode;

/** Spawns the objects of all object layers and adds them as child nodes to their corresponding objectLayerNode.
 The object's classes and properties are defined in objects.lua. */
-(void) spawnObjects;
/** Spawns the objects of an object layer and adds them as child nodes to the objectLayerNode.
 The object's classes and properties are defined in objects.lua. 
 @param objectLayerNode The object layer node for which to spawn objects. */
-(void) spawnObjectsWithLayerNode:(KKTilemapObjectLayerNode*)objectLayerNode;

/** Enables boundary scrolling. This prevents the map's main tile layer from ever scrolling outside its bounds. */
-(void) restrictScrollingToMapBoundary;

/** Enables parallax scrolling which makes other layers follow the main tile layer's position with parallax offset.
 Call this *after* setting up any camera follow object. */
-(void) enableParallaxScrolling;

@end
