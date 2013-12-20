/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "SKAction+KoboldKit.h"

@implementation SKAction (KoboldKit)

+(SKAction*) playSoundFileNamed:(NSString *)soundFile
{
	return [SKAction playSoundFileNamed:soundFile waitForCompletion:NO];
}

+ (instancetype) afterDelay:(NSTimeInterval)duration perform:(SKAction *)action
{
    return [SKAction sequence:@[[SKAction waitForDuration:duration], action]];
}

+ (instancetype) afterDelay:(NSTimeInterval)duration runBlock:(dispatch_block_t)block
{
    return [self afterDelay:duration perform:[SKAction runBlock:block]];
}

+ (instancetype) removeSelfAfterDelay:(NSTimeInterval)duration
{
    return [self afterDelay:duration perform:[SKAction removeFromParent]];
}


@end
