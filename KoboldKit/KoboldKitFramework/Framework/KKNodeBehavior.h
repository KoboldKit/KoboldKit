//
//  KKNodeBehavior.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKCompatibility.h"

@class KKNode;
@class KKNodeController;

/** Behaviors add custom logic to a node.
 Behaviors differ from actions in several ways:
 - they are useful for any logic code that is hard or impossible to implement with (custom) actions, such as event processing
 - they usually run indefinitely and can be paused by pausing the controller
 - they may have a state (ivars)
 - they may have a public interface (properties, methods)
 - they can not be reversed
 */
@interface KKNodeBehavior : NSObject <NSCoding, NSCopying>
{
	@protected
	BOOL _wantsUpdate;
	
	@private
}

@property (atomic, copy, readonly) NSString* key;

/** @returns The behavior's name. */
@property (atomic, copy) NSString* name;
/** @returns The behavior's node controller. */
@property (atomic, weak) KKNodeController* controller;
/** @returns The behavior's owning node. */
@property (atomic, weak) SKNode* node;
/** @returns Whether the behavior wants to receive update/didSimulatePhysics/didEvaluateActions messages.
 Usually set by custom subclasses. Just set wantsUpdate to YES and implement the methods you want called every frame. */
@property (atomic, readonly) BOOL wantsUpdate;
/** @returns Whether the behavior is enabled. 
 Disabled behaviors don't receive update messages. */
@property (atomic) BOOL enabled;

/** Creates a new instance.
 @returns The new instance. */
+(id) behavior;

/** Removes the behavior from its owning node and controller. */
-(void) removeFromNode;

/** Sent when the behavior was added to a node. */
-(void) didJoinController;
/** Sent when the behavior was removed from a node. */
-(void) didLeaveController;

/** Standard update method.
 @param currentTime The current time since app start. */
-(void) update:(NSTimeInterval)currentTime;
/** Update after actions have been evaluated. */
-(void) didEvaluateActions;
/** Update after physics world was simulated. */
-(void) didSimulatePhysics;


/** Posts a notification to notification center, with userInfo "behavior" key pointing to the sending behavior object.
 @param name The uniquely identifying name of the notification. */
-(void) postNotificationName:(NSString*)name;
/** Posts a notification to notification center, with userInfo "behavior" key pointing to the sending behavior object, and custom userInfo keys. 
 @param name The uniquely identifying name of the notification. 
 @param userInfo A dictionary with custom key/value which the notification receiver may need. A key "behavior" containing the
 sending behavior object is always added to the dictionary. */
-(void) postNotificationName:(NSString*)name userInfo:(NSDictionary*)userInfo;


// internal use
-(BOOL) isEqualToBehavior:(KKNodeBehavior*)behavior;
-(void) internal_joinController:(KKNodeController*)controller withKey:(NSString*)key;

@end
