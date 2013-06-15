//
//  MyScene.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "MyScene.h"
#import "KoboldKit.h"
#import "MyLabelNode.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
	{
        /* Setup your scene here */
		
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        myLabel = [MyLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:myLabel];
		
		[myLabel addBehavior:[KKButtonBehavior new] withKey:@"labelbutton1"];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(labelButtonDidExecute:) name:KKButtonDidExecute object:myLabel];
		
		KKLabelNode* otherLabel = [KKLabelNode labelNodeWithFontNamed:@"Arial"];
        otherLabel.text = @"Buttong!";
        otherLabel.fontSize = 30;
        otherLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100);
        [self addChild:otherLabel];
		
		[otherLabel addBehavior:[KKButtonBehavior new] withKey:@"labelbutton2"];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherLabelButtonDidExecute:) name:KKButtonDidExecute object:otherLabel];

		NSLog(@"userdata: %@", self.userData);
		NSLog(@"search nodes: %@", [self childNodeWithName:@"//*"]);
    }
    return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) labelButtonDidExecute:(NSNotification*) note
{
	LOG_EXPR(note);
	[note.object removeBehaviorForKey:@"labelbutton1"];
}

-(void) otherLabelButtonDidExecute:(NSNotification*) note
{
	LOG_EXPR(note);
	KKNodeBehavior* behavior = [note.userInfo objectForKey:@"behavior"];
	[(KKNode*)note.object removeBehavior:behavior];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
    for (UITouch *touch in touches)
	{
		//[(KKButtonBehavior*)[myLabel behaviorForKey:@"button"] touchesBegan:touches withEvent:event];
		
		/*
        CGPoint location = [touch locationInNode:self];
        
        KKSpriteNode *sprite = [KKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        sprite.position = location;
        [self addChild:sprite];
        
        KKAction *action = [KKAction rotateByAngle:M_PI duration:1];
        [sprite runAction:[KKAction repeatActionForever:action]];
		 */
    }
}

-(void)update:(NSTimeInterval)currentTime
{
	// calling super will update controllers and behaviors, also advanced frame counter
	[super update:currentTime];
}

@end
