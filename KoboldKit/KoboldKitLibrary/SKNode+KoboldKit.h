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

/** Kobold Kit extensions to SKNode. Adds access to controller, model and behaviors. */
@interface SKNode (KoboldKit)

/** @name Changing the Node's Position */

/** (not documented) */
-(void) centerOnNode:(SKNode*)node;

/** @name Observing Node's Child Status */

/** Called after addChild / insertChild. The self.scene and self.parent properties are valid in this method. */
-(void) didMoveToParent;
/** Called after removeFromParent and other remove child methods. The self.scene and self.parent properties are still valid. */
-(void) willMoveFromParent;

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

/** @name Scheduling Selectors */

/** (not documented) */
-(void) performSelector:(SEL)aSelector afterDelay:(NSTimeInterval)delay;
/** (not documented) */
-(void) performSelectorInBackground:(SEL)aSelector;

/** @name Subscribe to input events */

/** (not documented) */
-(void) observeInputEvents;
/** (not documented) */
-(void) disregardInputEvents;

/** @name Subscribe to scene events */

/** (not documented) */
-(void) observeSceneEvents;
/** (not documented) */
-(void) disregardSceneEvents;

/** @name Subscribe to notifications */

/** (not documented) */
-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector;
/** (not documented) */
-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector object:(id)notificationSender;
/** (not documented) */
-(void) disregardNotification:(NSString*)notificationName;
/** (not documented) */
-(void) disregardNotification:(NSString*)notificationName object:(id)notificationSender;
/** (not documented) */
-(void) disregardAllNotifications;


// internal use only
-(BOOL) isEqualToNode:(SKNode*)node;
-(BOOL) isEqualToNodeTree:(SKNode*)node;

@end


@interface SKScene (KoboldKit)
@end
@interface SKCropNode (KoboldKit)
@end
@interface SKEffectNode (KoboldKit)
@end
@interface SKEmitterNode (KoboldKit)
@end
@interface SKLabelNode (KoboldKit)
@end
@interface SKShapeNode (KoboldKit)
@end
@interface SKSpriteNode (KoboldKit)
@end
@interface SKVideoNode (KoboldKit)
@end
