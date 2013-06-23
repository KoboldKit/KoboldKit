//
//  KKFollowsTargetBehavior
//  KoboldKit
//
//  Created by Steffen Itterheim on 19.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "KKNodeBehavior.h"

/** Updates the owning node's position from another node's position, applying optional offset and/or multiplier.
 The multiplier can be used to achieve a parallaxing effect. */
@interface KKFollowTargetBehavior : KKNodeBehavior

/** (not documented) */
@property (nonatomic, weak) SKNode* target;
/** (not documented) */
@property (nonatomic) CGPoint positionMultiplier;
/** (not documented) */
@property (nonatomic) CGPoint positionOffset;

/** (not documented) */
+(id) followTarget:(SKNode*)target;
/** (not documented) */
+(id) followTarget:(SKNode*)target offset:(CGPoint)positionOffset;
/** (not documented) */
+(id) followTarget:(SKNode*)target offset:(CGPoint)positionOffset multiplier:(CGPoint)positionMultiplier;

@end
