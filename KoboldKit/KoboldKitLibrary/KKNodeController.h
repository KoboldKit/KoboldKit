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

@class KKNodeBehavior;
@class KKNodeModel;

/** KKNodeController adds game component (behavior, model) functionality to a node. */
@interface KKNodeController : NSObject <NSCoding, NSCopying>
{
	@private
	NSMutableArray* _behaviors;
	KKNodeModel* _model;
}

/** @returns The controller's owning node. You should never change this reference yourself! */
@property (atomic, weak) KKNode* node;
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
-(id) initWithBehaviors:(NSArray*)behaviors;

-(void) addBehavior:(KKNodeBehavior*)behavior;
-(void) addBehavior:(KKNodeBehavior*)behavior withKey:(NSString*)key;
-(void) addBehaviors:(NSArray*)behaviors;
-(KKNodeBehavior*) behaviorForKey:(NSString*)key;
-(BOOL) hasBehaviors;
-(void) removeBehavior:(KKNodeBehavior*)behavior;
-(void) removeBehaviorForKey:(NSString*)key;
-(void) removeAllBehaviors;

-(void) update:(NSTimeInterval)currentTime;

-(BOOL) isEqualToController:(KKNodeController*)controller;

@end
