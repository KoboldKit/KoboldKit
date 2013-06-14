//
//  SKNode+KoboldKit.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteKit.h"

@class KKNodeController;
@class KKNodeBehavior;
@class KKScene;

/** Kobold Kit extensions to SKNode */
@interface SKNode (KoboldKit)

/** @name Creating and Accessing the Controller */
/** Returns the node's controller object. */
@property (atomic) KKNodeController* controller;
/** Creates node controller if one does not exist yet. Returns the new or existing instance. */
-(KKNodeController*) createController;

/** @name Accessing the KKScene */
/** Returns the node's scene object, cast to KKScene. Use this instead of scene to use KKScene's methods and properties. */
@property (atomic, readonly) KKScene* kkScene;

/** @name Working with Behaviors */
/** Adds a behavior to the node. The behavior will be copied.
 @param behavior The behavior to add. */
-(void) addBehavior:(KKNodeBehavior*)behavior;
/** Adds a behavior to the node with a key. Replaces any existing behavior with the same key. The behavior will be copied. 
 @param behavior The behavior to add.
 @param key A unique key used to identify the behavior. */
-(void) addBehavior:(KKNodeBehavior*)behavior withKey:(NSString*)key;
/** Adds multiple behaviors from an array. The behaviors will be copied.
 @param behaviors An array containing behaviors to add. */
-(void) addBehaviors:(NSArray*)behaviors;
/** @returns The behavior for the key. Returns nil if no behavior with that key was found.
 @param key A unique key identifying the behavior. */
-(KKNodeBehavior*) behaviorForKey:(NSString*)key;
/** @returns YES if the node has one or more behaviors. */
-(BOOL) hasBehaviors;
/** Removes the behavior.
 @param behavior The behavior to remove. */
-(void) removeBehavior:(KKNodeBehavior*)behavior;
/** Removes the behavior with the given key.
 @param key The unique key identifying the behavior. */
-(void) removeBehaviorForKey:(NSString*)key;
/** Removes all behaviors from the node. */
-(void) removeAllBehaviors;

-(NSString*) kkDescription;
+(NSString*) descriptionForNode:(SKNode*)node;

-(instancetype) kkCopyWithZone:(NSZone*)zone;

/** @name Testing for Equality */

/** Ensures that the node's properties are equal. Compares controllers and behaviors too. Does not descend to its children.
 @returns YES if the receiver is considered equal to the other node. */
-(BOOL) isEqualToNode:(SKNode*)node;
/** Ensures that the node's properties are equal. Compares controllers and behaviors too. Descends and compares node children as well.
  @returns YES if the receiver and its children are considered equal to the other node and the other node's children. */
-(BOOL) isEqualToNodeTree:(SKNode*)node;

@end


@interface SKCropNode (KoboldKit)
-(NSString*) kkDescription;
@end
@interface SKEffectNode (KoboldKit)
-(NSString*) kkDescription;
@end
@interface SKEmitterNode (KoboldKit)
-(NSString*) kkDescription;
@end
@interface SKLabelNode (KoboldKit)
-(NSString*) kkDescription;
@end
@interface SKScene (KoboldKit)
-(NSString*) kkDescription;
@end
@interface SKShapeNode (KoboldKit)
-(NSString*) kkDescription;
@end
@interface SKSpriteNode (KoboldKit)
-(NSString*) kkDescription;
@end
@interface SKVideoNode (KoboldKit)
-(NSString*) kkDescription;
@end
