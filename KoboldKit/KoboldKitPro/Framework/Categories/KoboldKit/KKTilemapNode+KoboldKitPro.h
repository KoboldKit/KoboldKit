/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import "KKTilemapNode.h"

/** Kobold Kit Pro extensions to KKTilemapNode */
@interface KKTilemapNode (KoboldKitPro)

/** @name Spawning Objects */

/** Spawns the objects of all object layers and adds them as child nodes to their corresponding objectLayerNode.
 The object's classes and properties are defined in objects.lua. */
-(void) spawnObjects;
/** Spawns the objects of an object layer and adds them as child nodes to the objectLayerNode.
 The object's classes and properties are defined in objects.lua.
 @param objectLayerNode The object layer node for which to spawn objects. */
-(void) spawnObjectsWithLayerNode:(KKTilemapObjectLayerNode*)objectLayerNode;

/** @name Generating Physics Shapes */

/** Creates physics blocking shapes from the main tile layer's blocking tiles and the blockingTiles or nonBlockingTiles properties of tilesets.
 @param tileLayerNode The tile layer node for which to create physics shapes.
 @returns The node containing child nodes for each physics body created. */
-(SKNode*) createPhysicsShapesWithTileLayerNode:(KKTilemapTileLayerNode*)tileLayerNode;

/** Creates physics blocking shapes from an object layer's objects.
 @param objectLayerNode The object layer node from whose objects to create physics shapes.
 @returns The node containing child nodes for each physics body created. */
-(SKNode*) createPhysicsShapesWithObjectLayerNode:(KKTilemapObjectLayerNode*)objectLayerNode;

@end
