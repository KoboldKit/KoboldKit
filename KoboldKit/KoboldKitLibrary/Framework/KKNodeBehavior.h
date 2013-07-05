//
//  KKNodeBehavior.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKSpriteKit.h"
#import "KKMacros.h"

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

/** (not documented) */
@property (atomic, copy) NSString* name;
/** (not documented) */
@property (atomic, weak) KKNodeController* controller;
/** (not documented) */
@property (atomic, weak) SKNode* node;
/** (not documented) set by subclasses */
@property (atomic, readonly) BOOL wantsUpdate;
/** (not documented) */
@property (atomic) BOOL enabled;

/** nd */
+(id) behavior;

/** (not documented) */
-(void) removeFromNode;

/** (not documented) */
-(void) didJoinController;
/** (not documented) */
-(void) didLeaveController;

/** (not documented) */
-(void) update:(NSTimeInterval)currentTime;
/** (not documented) */
-(void) didEvaluateActions;
/** (not documented) */
-(void) didSimulatePhysics;


/** (not documented) posts a notification to notification center, with userInfo "behavior" key pointing to the sending behavior object. */
-(void) postNotificationName:(NSString*)name;
/** (not documented) posts a notification to notification center, with userInfo "behavior" key pointing to the sending behavior object, and custom userInfo keys. */
-(void) postNotificationName:(NSString*)name userInfo:(NSDictionary*)userInfo;


// internal use
-(BOOL) isEqualToBehavior:(KKNodeBehavior*)behavior;
-(void) internal_joinController:(KKNodeController*)controller withKey:(NSString*)key;

@end
