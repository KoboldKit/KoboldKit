//
//  KKEmitterNode.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 03.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKEmitterNode.h"
#import "KKNodeShared.h"

@implementation KKEmitterNode
KKNODE_SHARED_CODE

+(id) emitterWithFile:(NSString*)file
{
	return [NSKeyedUnarchiver unarchiveObjectWithFile:[NSBundle pathForFile:file]];
}

@end
