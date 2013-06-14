//
//  SKNode+KoboldKit.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteKit.h"

@class KKNodeController;
@class KKBehavior;
@class KKScene;

/** Kobold Kit extensions to SKNode */
@interface SKNode (KoboldKit)

/** Returns the node's controller object. */
@property (atomic) KKNodeController* controller;
/** Returns the node's scene object, cast to KKScene. Use this instead of scene to use KKScene's methods and properties. */
@property (atomic, readonly) KKScene* kkScene;

/** Creates node controller if one does not exist yet. Returns the new or existing instance. */
-(KKNodeController*) createController;

/** Adds a behavior to the node. */
-(void) addBehavior:(KKBehavior*)behavior;
/** Adds a behavior to the node with a key. Replaces any existing behavior with the same key. */
-(void) addBehavior:(KKBehavior*)behavior withKey:(NSString*)key;
/** Adds multiple behaviors from an array. */
-(void) addBehaviors:(NSArray*)behaviors;
/** Returns the behavior for the key. Returns nil if no behavior with that key was found. */
-(KKBehavior*) behaviorForKey:(NSString*)key;
/** Returns YES if the node has one or more behaviors. */
-(BOOL) hasBehaviors;
/** Removes the behavior. */
-(void) removeBehavior:(KKBehavior*)behavior;
/** Removes the behavior with the given key. */
-(void) removeBehaviorForKey:(NSString*)key;
/** Removes all behaviors from the node. */
-(void) removeAllBehaviors;

-(NSString*) kkDescription;
+(NSString*) descriptionForNode:(SKNode*)node;

-(instancetype) kkCopyWithZone:(NSZone*)zone;

/** Ensures that the node's properties are equal. Compares controllers and behaviors too. Does not descend to its children. */
-(BOOL) isEqualToNode:(SKNode*)node;
/** Ensures that the node's properties are equal. Compares controllers and behaviors too. Descends and compares node children as well. */
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
