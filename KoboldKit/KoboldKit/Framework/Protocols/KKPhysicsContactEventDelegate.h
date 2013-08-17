//
//  KKPhysicsContactEventDelegate.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 02.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKFramework.h"

@protocol KKPhysicsContactEventDelegate <NSObject>

@required

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