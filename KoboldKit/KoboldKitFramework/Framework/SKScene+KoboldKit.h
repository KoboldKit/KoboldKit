//
//  SKScene+KoboldKit.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 26.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKScene (KoboldKit)

-(void) enumerateBodiesUsingBlock:(void (^)(SKPhysicsBody *body, BOOL *stop))block;

/** @name Subscribe to notifications */

/** (not documented) */
-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector;
/** (not documented) */
-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector object:(id)notificationSender;
/** (not documented) */
-(void) disregardNotification:(NSString*)notificationName;
/** (not documented) */
-(void) disregardNotification:(NSString*)notificationName object:(id)notificationSender;
/** (not documented) */
-(void) disregardAllNotifications;

@end
