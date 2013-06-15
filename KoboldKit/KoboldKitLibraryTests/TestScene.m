//
//  TestScene.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 14.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "TestScene.h"
#import "KoboldKit.h"

@implementation TestScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
	{
        self.backgroundColor = [SKColor colorWithRed:1 green:0 blue:1 alpha:1];
        
		/*
		KKLabelNode* otherLabel = [KKLabelNode labelNodeWithFontNamed:@"Arial"];
        otherLabel.text = @"Buttong!";
        otherLabel.fontSize = 30;
        otherLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100);
        [self addChild:otherLabel];
		
		
		[otherLabel addBehavior:[KKButtonBehavior new] withKey:@"labelbutton"];
		*/
    }
    return self;
}

-(void) update:(NSTimeInterval)currentTime
{
	NSLog(@"update");
}

@end
