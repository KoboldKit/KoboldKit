//
//  KKNodeController.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKSpriteKit.h"

extern NSString* const KKNodeControllerUserDataKey;

@class KKNode;
@class KKNodeBehavior;
@class KKNodeModel;

/** KKNodeController adds game component (behavior, model) functionality to a node. */
@interface KKNodeController : NSObject <NSCoding, NSCopying>
{
	@private
	NSMutableArray* _behaviors;
	KKNodeModel* _model;
	BOOL _hasBehaviorWantingUpdate;
}

/** @returns The controller's owning node. You should never change this reference yourself! */
@property (atomic, weak) SKNode* node;
/** @returns The controller's userData supercedes the node's userData and can be used in the same way. You should never change this reference yourself! */
@property (atomic, strong) NSMutableDictionary* userData;
/** @returns The list of behaviors of the node. */
@property (atomic, readonly) NSArray* behaviors;
/** @returns The model object associated with this controller/node. */
@property (atomic) KKNodeModel* model;
/** If the controller is paused, the behaviors will stop receiving updates. Behaviors receiving events should
 also check the controller's paused state to ensure they don't process/forward events while paused.
 @returns The current paused status. */
@property (atomic) BOOL paused;

/** Creates a controller with a list of behaviors. */
+(id) controllerWithBehaviors:(NSArray*)behaviors;
/** (not documented) */
-(id) initWithBehaviors:(NSArray*)behaviors;

/** (not documented) */
-(void) addBehavior:(KKNodeBehavior*)behavior;
/** (not documented) */
-(void) addBehavior:(KKNodeBehavior*)behavior withKey:(NSString*)key;
/** (not documented) */
-(void) addBehaviors:(NSArray*)behaviors;
/** (not documented) */
-(KKNodeBehavior*) behaviorForKey:(NSString*)key;
/** (not documented) */
-(BOOL) hasBehaviors;
/** (not documented) */
-(void) removeBehavior:(KKNodeBehavior*)behavior;
/** (not documented) */
-(void) removeBehaviorForKey:(NSString*)key;
/** (not documented) */
-(void) removeAllBehaviors;

/** (not documented) */
-(void) update:(NSTimeInterval)currentTime;
/** (not documented) */
-(void) didEvaluateActions;
/** (not documented) */
-(void) didSimulatePhysics;

// internal use
-(BOOL) isEqualToController:(KKNodeController*)controller;

@end
