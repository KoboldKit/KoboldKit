//
//  KKBehavior.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKSpriteKit.h"
#import "KKMacros.h"

@class KKNodeController;

/** Behaviors add custom logic to a node.
 Behaviors differ from actions in several ways:
 - they are useful for any logic code that is hard or impossible to implement with (custom) actions, such as event processing
 - they usually run indefinitely and can be paused by pausing the controller
 - they may have a state (ivars)
 - they may have a public interface (properties, methods)
 - they can not be reversed
 */
@interface KKBehavior : NSObject <NSCoding, NSCopying>

@property (atomic, readonly) NSString* key;
@property (atomic, weak) KKNodeController* controller;
@property (atomic, weak) KKNode* node;
@property (atomic) BOOL wantsUpdate;

-(void) internal_joinController:(KKNodeController*)controller withKey:(NSString*)key;
-(void) internal_leaveController;

-(void) didJoinController;
-(void) didLeaveController;

-(void) update:(NSTimeInterval)currentTime;

@end
