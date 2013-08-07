//
//  SKAction+KoboldKit.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 07.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "SKAction+KoboldKit.h"

@implementation SKAction (KoboldKit)

+(SKAction*) playSoundFileNamed:(NSString *)soundFile
{
	return [SKAction playSoundFileNamed:soundFile waitForCompletion:NO];
}

@end
