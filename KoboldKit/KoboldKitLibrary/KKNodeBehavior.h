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

/** (not documented) */
@property (atomic, readonly) NSString* key;
/** (not documented) */
@property (atomic, weak) KKNodeController* controller;
/** (not documented) */
@property (atomic, weak) SKNode* node;
/** (not documented) set by subclasses */
@property (atomic, readonly) BOOL wantsUpdate;
/** (not documented) */
@property (atomic) BOOL enabled;

/** (not documented) */
+(id) behavior;

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


// internal use
-(BOOL) isEqualToBehavior:(KKNodeBehavior*)behavior;
-(void) internal_joinController:(KKNodeController*)controller withKey:(NSString*)key;

@end
