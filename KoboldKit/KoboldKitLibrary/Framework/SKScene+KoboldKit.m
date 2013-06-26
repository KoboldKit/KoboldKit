//
//  SKScene+KoboldKit.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 26.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "SKScene+KoboldKit.h"

@implementation SKScene (KoboldKit)

-(void) enumerateBodiesUsingBlock:(void (^)(SKPhysicsBody *body, BOOL *stop))block
{
	[self.physicsWorld enumerateBodiesInRect:CGRectMake(-INFINITY, -INFINITY, INFINITY, INFINITY) usingBlock:block];
}

@end
