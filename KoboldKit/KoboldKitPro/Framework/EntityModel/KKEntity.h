/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import <Foundation/Foundation.h>

typedef enum
{
	/** Static entities never move by themselves (velocity is ignored). */
	KKEntityTypeStatic,
	/** Kinematic entities will be updated before dynamic entities. They are not affected by gravity and don't perform collision resolve
	 (ie they can move through walls or push dynamic entities). */
	KKEntityTypeKinematic,
	/** Dynamic entities are affected by gravity and perform collision resolve. */
	KKEntityTypeDynamic,
	/** Players are dynamic entities but may be treated differently when it comes to collisions. They are also updated after all the other game elements. */
	KKEntityTypePlayer,
} KKEntityType;

/** An entity represents an object in a game world which is used to position its view (node), check for collisions
 and perform any other custom game logic. */
@interface KKEntity : NSObject

/** Current velocity. */
@property (atomic) CGPoint velocity;
/** Maximum velocity, in positive direction (will also cap negative velocity accordingly). Defaults to INFINITY. */
@property (atomic) CGPoint maximumVelocity;
/** Current position. */
@property (atomic) CGPoint position;
/** Current position, rounded to the next nearest pixel coordinate (ie 1.0, 1.5, 2.0, 2.5, etc). */
@property (atomic) CGPoint positionInPixels;
/** Position the object should appear in the world. Unless modified it is identical to initialPosition. */
@property (atomic) CGPoint spawnPosition;
/** Initial position is normally the position the object was positioned at in the editor. */
@property (atomic, readonly) CGPoint initialPosition;
/** Bounding box determines how big the entity is, used for collision detection. */
@property (atomic) CGRect boundingBox;

/** The node (if any) that represents the object visually. */
@property (atomic, weak) SKNode* node;

/** Type determines certain behaviors. */
@property (atomic) KKEntityType type;

/** Inactive objects still exist in memory but behave as if they didn't. */
//@property (atomic) BOOL active;

/** Creates an entity.
 @param node The node that represents the entity in the scene.
 @param tilemapObject The tilemap object that spawned the node and entity.
 @returns A new instance. */
+(id) entityWithNode:(SKNode*)node tilemapObject:(KKTilemapObject*)tilemapObject;

@end
