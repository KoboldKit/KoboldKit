/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"
#import "KKNode.h"
#import "KKTilemapObject.h"

@class KKTilemap;
@class KKTilemapTileLayerNode;
@class KKTilemapObjectLayerNode;
@class KKIntegerArray;

/** A tilemap node renders a TMX tilemap. It has KKTilemapTileLayerNode and KKTilempaObjectLayerNode as children
 which perform each layer's rendering. */
@interface KKTilemapNode : KKNode
{
	@protected
	NSMutableArray* _tileLayerNodes;
	NSMutableArray* _objectLayerNodes;
	KKTilemap* _tilemap;
	__weak KKTilemapTileLayerNode* _mainTileLayerNode;
}

/** @returns the tilemap model object containing the tilemap's data.*/
@property (atomic) KKTilemap* tilemap;

/** @returns an array containing all tile layer nodes */
@property (readonly) NSArray* tileLayerNodes;
/** @returns an array containing all object layer nodes */
@property (readonly) NSArray* objectLayerNodes;

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

/** Searches all object layers for an object with a matching name.
 @param name The name identifying the object.
 @returns The first object (of any object layer) with a matching name, or nil if no such object exists. */
-(KKTilemapObject*) objectNamed:(NSString*)name;

/** Enables boundary scrolling. This prevents the map's main tile layer from ever scrolling outside its bounds. */
-(void) restrictScrollingToMapBoundary;
/** Enables boundary scrolling. This prevents the map's main tile layer from ever scrolling outside the object's bounds. */
-(void) restrictScrollingToObject:(KKTilemapRectangleObject*)object;

/** Enables parallax scrolling which makes other layers follow the main tile layer's position with parallax offset.
 Call this *after* setting up any camera follow object. */
-(void) enableParallaxScrolling;

@end
