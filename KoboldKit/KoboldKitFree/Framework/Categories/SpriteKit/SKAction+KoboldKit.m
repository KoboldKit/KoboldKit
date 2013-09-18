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

@end
