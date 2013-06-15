//
//  MyLabelNode.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "MyLabelNode.h"

@implementation MyLabelNode

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"touching...");
	[self disregardInputEvents];
}

-(void) observe
{
	[self observeInputEvents];
}

@end
