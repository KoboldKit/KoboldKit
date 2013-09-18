/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"
#import "KKPhysicsContactEventDelegate.h"

extern NSString* const KKNodeControllerUserDataKey;

@class KKNode;
@class KKBehavior;
@class KKModel;

/** KKNodeController adds game component (behavior, model) functionality to a node. */
@interface KKNodeController : NSObject <KKPhysicsContactEventDelegate, NSCoding, NSCopying>
{
	@private
	NSMutableArray* _behaviors;
	NSMutableArray* _physicsDidBeginContactObservers;
	NSMutableArray* _physicsDidEndContactObservers;
	KKModel* _model;
	__weak SKNode* _node;
	BOOL _observingPhysicsContactEvents;
}

/** @returns The controller's owning node. You should never change this reference yourself! */
@property (atomic, weak) SKNode* node;
/** @returns The controller's userData supercedes the node's userData and can be used in the same way. You should never change this reference yourself! */
@property (atomic, strong) NSMutableDictionary* userData;
/** @returns The list of behaviors of the node. */
@property (atomic, readonly) NSArray* behaviors;
/** @returns The model object associated with this controller/node. */
@property (atomic) KKModel* model;
/** If the controller is paused, the behaviors will stop receiving updates. Behaviors receiving events should
 also check the controller's paused state to ensure they don't process/forward events while paused.
 @returns The current paused status. */
@property (atomic) BOOL paused;

/** Creates a controller with a list of behaviors.
 @param behaviors An array containing KKBehavior objects.
 @returns A new instance. */
+(id) controllerWithBehaviors:(NSArray*)behaviors;
/** Creates a controller with a list of behaviors.
 @param behaviors An array containing KKBehavior objects.
 @returns A new instance. */
-(id) initWithBehaviors:(NSArray*)behaviors;

/** Adds a behavior.
 @param behavior The behavior to add. */
-(void) addBehavior:(KKBehavior*)behavior;
/** Adds a behavior with key.
 @param behavior The behavior to add.
 @param key The behavior's uniquely identifying key. */
-(void) addBehavior:(KKBehavior*)behavior withKey:(NSString*)key;
/** Adds a list of behaviors.
 @param behaviors An array containing KKBehavior objects. */
-(void) addBehaviors:(NSArray*)behaviors;
/** @param key A key uniquely identifying the behavior.
 @returns The behavior for the key or nil if there is no behavior with that key. */
-(id) behaviorForKey:(NSString*)key;
/** @param behaviorClass The class uniquely identifying the behavior.
 @returns The first found behavior being a kind of class or nil if there is no behavior with that class. */
-(id) behaviorKindOfClass:(Class)behaviorClass;
/** @param behaviorClass The class uniquely identifying the behavior.
 @returns The first found behavior being a member of the class or nil if there is no behavior with that class. */
-(id) behaviorMemberOfClass:(Class)behaviorClass;
/** @returns YES if the controller has one or more behaviors. */
-(BOOL) hasBehaviors;
/** Removes a specific behavior. Does nothing if the behavior isn't in the list.
 @param behavior The behavior to remove */
-(void) removeBehavior:(KKBehavior*)behavior;
/** Removes a specific behavior by key. Does nothing if there's no behavior with this key in the list.
 @param key The key uniquely identifying the behavior to remove. */
-(void) removeBehaviorForKey:(NSString*)key;
/** Removes a specific behavior by class. Does nothing if there's no behavior being a member of the class in the list.
 @param behaviorClass The behavior class to remove. */
-(void) removeBehaviorWithClass:(Class)behaviorClass;
/** Removes all behaviors from the controller. */
-(void) removeAllBehaviors;

// internal use
-(BOOL) isEqualToController:(KKNodeController*)controller;
-(void) willRemoveController;
-(void) nodeDidMoveToParent;
-(void) nodeWillMoveFromParent;

@end
