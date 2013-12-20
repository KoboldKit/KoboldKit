/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import <SpriteKit/SpriteKit.h>

#define removeSelfAfterDelay afterDelayRemoveSelf

/** nd */
@interface SKAction (KoboldKit)

/** nd */
+(instancetype) playSoundFileNamed:(NSString *)soundFile;

/** Returns a sequence consisting of waitForDuration followed by some action.
 @param duration time to wait before performing this action
 @param action the action to perform after waiting */
+ (instancetype) afterDelay:(NSTimeInterval)duration perform:(SKAction *)action;

/** Returns a sequence consisting of waitForDuration followed by runBlock
 @param duration time to wait before executing the block
 @param block the block to execute after waiting */
+ (instancetype) afterDelay:(NSTimeInterval)duration runBlock:(dispatch_block_t)block;

/** Returns a sequence consisting of waitForDuration followed by removeFromParent.
 @param duration time to wait before removing this node from its parent */
+ (instancetype) afterDelayRemoveSelf:(NSTimeInterval)duration;

@end
