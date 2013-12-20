/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import <SpriteKit/SpriteKit.h>
#import "KKBehavior.h"

/** Updates the owning node's position from another node's position, applying optional offset and/or multiplier.
 The multiplier can be used to achieve a parallaxing effect. */
@interface KKFollowTargetBehavior : KKBehavior <KKSceneEventDelegate>

/** The target the behavior's node is following. */
@property (atomic, weak) SKNode* target;
/** The target's position is multiplied by this position multiplier before the resulting point is set as the node's position. */
@property (atomic) CGPoint positionMultiplier;
/** The target's position has this offset added before the resulting point is set as the node's position. */
@property (atomic) CGPoint positionOffset;

/** Follow another node.
 @param target The node to follow.
 @returns A new instance. */
+(id) followTarget:(SKNode*)target;
/** Follow another node at an offset.
 @param target The node to follow.
 @param positionOffset The offset to add to the target's position.
 @returns A new instance. */
+(id) followTarget:(SKNode*)target offset:(CGPoint)positionOffset;
/** Follow another node at an offset with multiplier (for parallaxing effect).
 @param target The node to follow.
 @param positionOffset The offset to add to the target's position.
 @param positionMultiplier Multiply the target position by these multipliers.
 @returns A new instance. */
+(id) followTarget:(SKNode*)target offset:(CGPoint)positionOffset multiplier:(CGPoint)positionMultiplier;

@end
