/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKEmitterNode.h"
#import "KKNodeShared.h"

@implementation KKEmitterNode
KKNODE_SHARED_CODE

+(instancetype) emitterWithFile:(NSString*)file
{
	return [NSKeyedUnarchiver unarchiveObjectWithFile:[NSBundle pathForFile:file]];
}

@end
