//
//  KKLimitVelocityBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 04.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKNodeBehavior.h"

/** Sets upper and lower limits of a physics body's velocities. */
@interface KKLimitVelocityBehavior : KKNodeBehavior

@property (atomic) CGFloat velocityLimit;
@property (atomic) CGFloat angularVelocityLimit;

+(id) limitVelocity:(CGFloat)velocityLimit;
+(id) limitVelocity:(CGFloat)velocityLimit limitAngularVelocity:(CGFloat)angularVelocityLimit;
+(id) limitAngularVelocity:(CGFloat)angularVelocityLimit;

@end
