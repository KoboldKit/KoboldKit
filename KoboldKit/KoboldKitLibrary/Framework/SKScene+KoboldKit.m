//
//  SKScene+KoboldKit.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 26.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "SKScene+KoboldKit.h"
#import "SKNode+KoboldKit.h"

@implementation SKScene (KoboldKit)

-(void) enumerateBodiesUsingBlock:(void (^)(SKPhysicsBody *body, BOOL *stop))block
{
	[self.physicsWorld enumerateBodiesInRect:CGRectMake(-INFINITY, -INFINITY, INFINITY, INFINITY) usingBlock:block];
}

#pragma mark Notifications

-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:notificationSelector name:notificationName object:nil];
}
-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector object:(id)notificationSender
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:notificationSelector name:notificationName object:notificationSender];
}
-(void) disregardNotification:(NSString*)notificationName
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
}
-(void) disregardNotification:(NSString*)notificationName object:(id)notificationSender
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:notificationSender];
}
-(void) disregardAllNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
