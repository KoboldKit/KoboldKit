/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"

@protocol KKPhysicsContactEventDelegate <NSObject>

@optional

/** @returns The physics contact delegate's owning node. */
@property (atomic, weak) SKNode* node;

/** Called when two objects's physics bodies get in contact.
 @param contact The contact object.
 @param otherBody The other contacting body. */
-(void) didBeginContact:(SKPhysicsContact*)contact otherBody:(SKPhysicsBody*)otherBody;

/** Called when two objects's physics bodies' contact ends.
 @param contact The contact object.
 @param otherBody The other contacting body. */
-(void) didEndContact:(SKPhysicsContact*)contact otherBody:(SKPhysicsBody*)otherBody;

@end