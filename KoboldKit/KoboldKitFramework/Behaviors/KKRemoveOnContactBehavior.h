//
//  KKRemoveOnContactBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 01.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"

/** This behavior removes the node when its physicsBody generates a contact event. */
@interface KKRemoveOnContactBehavior : KKBehavior

-(void) didBeginContact:(SKPhysicsContact *)contact;

@end
