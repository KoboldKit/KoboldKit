/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import <SpriteKit/SpriteKit.h>

/** SKScene category methods for Kobold Kit */
@interface SKScene (KoboldKit)

/** Enumerates all physics bodies in the world by passing an INFINITY rect to enumerateBodiesInRect.
 @param block The block that is called for every physics body. */
-(void) enumerateBodiesUsingBlock:(void (^)(SKPhysicsBody *body, BOOL *stop))block;

/** @name Subscribe to notifications */

/** Receiver observes notifications posted by notification center.
 @param notificationName A string uniquely identifying the notification.
 @param notificationSelector The selector that is performed when a matching notification was received. Selector takes a single NSNotification object as parameter. */
-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector;
/** Receiver observes notifications posted by notification center but only those notifications posted by a specific object.
 @param notificationName A string uniquely identifying the notification.
 @param notificationSelector The selector that is performed when a matching notification was received. Selector takes a single NSNotification object as parameter.
 @param notificationSender The notification sender object whose notifications are observed. */
-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector object:(id)notificationSender;
/** Receiver disregards all notifications with the given name.
 @param notificationName A string uniquely identifying the notification. */
-(void) disregardNotification:(NSString*)notificationName;
/** Receiver disregards notifications with the given name coming from a specific object.
 @param notificationName A string uniquely identifying the notification.
 @param notificationSender The notification sender object whose notifications are observed. */
-(void) disregardNotification:(NSString*)notificationName object:(id)notificationSender;
/** Receiver disregards any and all notification sent by the notification center. */
-(void) disregardAllNotifications;

@end
