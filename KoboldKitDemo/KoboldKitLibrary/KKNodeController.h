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

@class KKBehavior;

@interface KKNodeController : NSObject <NSCoding, NSCopying>
{
	@private
	NSMutableArray* _behaviors;
}

@property (atomic, weak) KKNode* node;
@property (atomic, retain) NSMutableDictionary* userData;
@property (atomic, readonly) NSArray* behaviors;
@property (atomic) BOOL paused;

+(id) controller;
+(id) controllerWithBehaviors:(NSArray*)behaviors;
-(id) initWithBehaviors:(NSArray*)behaviors;

-(void) addBehavior:(KKBehavior*)behavior;
-(void) addBehavior:(KKBehavior*)behavior withKey:(NSString*)key;
-(void) addBehaviors:(NSArray*)behaviors;
-(KKBehavior*) behaviorForKey:(NSString*)key;
-(BOOL) hasBehaviors;
-(void) removeBehavior:(KKBehavior*)behavior;
-(void) removeBehaviorForKey:(NSString*)key;
-(void) removeAllBehaviors;

-(void) update:(NSTimeInterval)currentTime;

@end
