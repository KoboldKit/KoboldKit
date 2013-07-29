//
//  KKLimitVelocityBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 04.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"

/** Sets upper and lower limits of a physics body's velocities. */
@interface KKLimitVelocityBehavior : KKBehavior

/** The physics body's maximum linear velocity (movement speed). */
@property (atomic) CGFloat velocityLimit;
/** The physics body's maximum angular velocity (rotation speed). */
@property (atomic) CGFloat angularVelocityLimit;

/** @param velocityLimit The physics body's maximum velocity.
 @returns A new instance. */
+(id) limitVelocity:(CGFloat)velocityLimit;
/** @param velocityLimit The physics body's maximum velocity.
 @param angularVelocityLimit The physics body's maximum angular velocity.
 @returns A new instance. */
+(id) limitVelocity:(CGFloat)velocityLimit limitAngularVelocity:(CGFloat)angularVelocityLimit;
/**  @param angularVelocityLimit The physics body's maximum angular velocity.
 @returns A new instance. */
+(id) limitAngularVelocity:(CGFloat)angularVelocityLimit;

@end
