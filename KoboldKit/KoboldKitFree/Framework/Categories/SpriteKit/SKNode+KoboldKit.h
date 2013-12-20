/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"
#import "KKPhysicsContactEventDelegate.h"
#import "KKSceneEventDelegate.h"

@class KKNodeController;
@class KKBehavior;
@class KKScene;
@class KKTilemapObject;
@class KKModel;

/** Kobold Kit extensions to SKNode. Adds access to controller, model and behaviors. */
@interface SKNode (KoboldKit) <KKPhysicsContactEventDelegate, KKSceneEventDelegate>

/** @name Changing the Node's Position */

/** Changes the receiver's position so that it is centered on the given node.
 @param node The node to center on. */
-(void) centerOnNode:(SKNode*)node;

/** @name Observing Node's Child Status */

/** Called after addChild / insertChild. The self.scene and self.parent properties are valid in this method. */
-(void) didMoveToParent;
/** Called after removeFromParent and other remove child methods. The self.scene and self.parent properties are still valid. */
-(void) willMoveFromParent;

/** @name Working with Controllers */

/** @returns the node's controller object. */
@property (atomic) KKNodeController* controller;
/** Creates node controller if one does not exist yet. Returns the new or existing instance. */
-(KKNodeController*) createController;
/** Removes the controller from the node. */
-(void) removeController;

/** @returns The node's model */
@property (atomic, readonly) KKModel* model;
/** @returns The node's model */
@property (atomic, readonly) KKModel* info; // alias

/** Pauses all controllers of the nodes beginning with rootNode.
 @param rootNode The node whose node tree will be paused. */
-(void) pauseControllersInNodeTree:(SKNode*)rootNode;
/** Resumes all controllers of the nodes beginning with rootNode.
 @param rootNode The node whose node tree will be resumed. */
-(void) resumeControllersInNodeTree:(SKNode*)rootNode;

/** @name Accessing the KKScene */

/** Returns the node's scene object, cast to KKScene. Use this instead of scene to use KKScene's methods and properties. */
@property (atomic, readonly) KKScene* kkScene;

/** @name Working with Behaviors */

/** Adds a behavior to the node. The behavior will be copied.
 @param behavior The behavior to add. */
-(void) addBehavior:(KKBehavior*)behavior;
/** Adds a behavior to the node with a key. Replaces any existing behavior with the same key. The behavior will be copied. 
 @param behavior The behavior to add.
 @param key A unique key used to identify the behavior. */
-(void) addBehavior:(KKBehavior*)behavior withKey:(NSString*)key;
/** Adds multiple behaviors from an array. The behaviors will be copied.
 @param behaviors An array containing behaviors to add. */
-(void) addBehaviors:(NSArray*)behaviors;
/** @returns The behavior for the key. Returns nil if no behavior with that key was found.
 @param key A unique key identifying the behavior. */
-(id) behaviorForKey:(NSString*)key;
/** @returns The first behavior of the given kind of class. Returns nil if no behavior with that class was found.
 @param behaviorClass The Class of the behavior. */
-(id) behaviorKindOfClass:(Class)behaviorClass;
/** @returns The first behavior that is a member of the given class. Returns nil if no behavior with that class was found.
 @param behaviorClass The Class of the behavior. */
-(id) behaviorMemberOfClass:(Class)behaviorClass;
/** @returns YES if the node has one or more behaviors. */
-(BOOL) hasBehaviors;
/** Removes the behavior.
 @param behavior The behavior to remove. */
-(void) removeBehavior:(KKBehavior*)behavior;
/** Removes the behavior with the given key.
 @param key The unique key identifying the behavior. */
-(void) removeBehaviorForKey:(NSString*)key;
/** Removes the first behavior with the given class.
 @param behaviorClass The Class of the behavior. */
-(void) removeBehaviorWithClass:(Class)behaviorClass;
/** Removes all behaviors from the node. */
-(void) removeAllBehaviors;

/** @name Subscribe to input events */

/** Receiver starts receiving input events. The receiver will receive any event method for touches,
 accelerometer, keyboard, mouse by simply implementing the corresponding input event method (ie touchesBegan:withEvent:). */
-(void) observeInputEvents;
/** Receiver stops receiving all input events. */
-(void) disregardInputEvents;

/** @name Subscribe to scene events */

/** Receiver starts receiving all scene events. These events include update, didSimulatePhysics, didEvaluateActions as well as
 scene resizing and scene move to/from view. Receiver only needs to implement the corresponding event methods. */
-(void) observeSceneEvents;
/** Receiver stops receiving all scene events. */
-(void) disregardSceneEvents;

/** @name Subscribe to physics contact events */

/** Receiver starts receiving both physics contact events. Receiver only needs to implement the corresponding event methods. */
-(void) observePhysicsContactEvents;
/** Receiver stops receiving the physics contact events. */
-(void) disregardPhysicsContactEvents;

/** @name Subscribe to notifications */

/** Receiver observes notifications posted by notification center.
 @param notificationName A string uniquely identifying the notification.
 @param notificationSelector The selector that is performed when a matching notification was received. Selector takes a single NSNotification object as parameter. */
-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector;
/** Receiver observes notifications posted by notification center but only those notifications posted by a specific object.
 @param notificationName A string uniquely identifying the notification.
 @param notificationSelector The selector that is performed when a matching notification was received. Selector takes a single NSNotification object as parameter.
 @param notificationSender The notification sender object whose notifications are observed. */
-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector object:(id)notificationSender;
/** Receiver disregards all notifications with the given name.
 @param notificationName A string uniquely identifying the notification. */
-(void) disregardNotification:(NSString*)notificationName;
/** Receiver disregards notifications with the given name coming from a specific object.
 @param notificationName A string uniquely identifying the notification.
 @param notificationSender The notification sender object whose notifications are observed. */
-(void) disregardNotification:(NSString*)notificationName object:(id)notificationSender;
/** Receiver disregards any and all notification sent by the notification center. */
-(void) disregardAllNotifications;


/** Creates a physics Body with edge loop shape. Also assigns the physics body to the node's self.physicsBody property.
 @param path The CGPath with edge points.
 @returns The newly created SKPhysicsBody. */
-(SKPhysicsBody*) physicsBodyWithEdgeLoopFromPath:(CGPathRef)path;
/** Creates a physics Body with edge chain shape. Also assigns the physics body to the node's self.physicsBody property.
 @param path The CGPath with chain points.
 @returns The newly created SKPhysicsBody. */
-(SKPhysicsBody*) physicsBodyWithEdgeChainFromPath:(CGPathRef)path;
/** Creates a physics Body with rectangle shape. Also assigns the physics body to the node's self.physicsBody property.
 @param size The size of the rectangle.
 @returns The newly created SKPhysicsBody. */
-(SKPhysicsBody*) physicsBodyWithRectangleOfSize:(CGSize)size;
/** Creates a physics Body with circle shape. Also assigns the physics body to the node's self.physicsBody property.
 @param radius The circle radius.
 @returns The newly created SKPhysicsBody. */
-(SKPhysicsBody*) physicsBodyWithCircleOfRadius:(CGFloat)radius;

/** nd */
-(SKPhysicsBody*) physicsBodyWithTilemapObject:(KKTilemapObject*)tilemapObject;

/** nd */
-(void) playSoundFileNamed:(NSString*)soundFile;

// internal use only
-(BOOL) isEqualToNode:(SKNode*)node;
-(BOOL) isEqualToNodeTree:(SKNode*)node;

@end

#pragma mark SK*Node Categories

@interface SKSpriteNode (KoboldKit)
@property (nonatomic) NSString* imageName;
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
@interface SKVideoNode (KoboldKit)
@end
