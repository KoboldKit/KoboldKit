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

#import <objc/runtime.h>

@implementation MyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
	{
        /* Setup your scene here */
		
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];

		//KKTilemapNode* tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:@"crawl-tilemap.tmx"];
		KKTilemapNode* tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:@"forest-parallax.tmx"];
		[self addChild:tilemapNode];
		tilemapNode.name = @"tilemap";
		
		//tilemapNode.xScale = 0.7f;
		//tilemapNode.yScale = 0.7f;
		//[tilemapNode.mainTileLayerNode runAction:[SKAction scaleTo:2.0f duration:20]];
		tilemapNode.mainTileLayerNode.position = CGPointMake(0, -110);
		[tilemapNode.mainTileLayerNode runAction:[SKAction moveByX:-10500 y:0 duration:120]];

		
        myLabel = [MyLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:myLabel];
		
		[myLabel addBehavior:[KKButtonBehavior new] withKey:@"labelbutton1"];
		[self observeNotification:KKButtonDidExecute
						 selector:@selector(labelButtonDidExecute:)
						   object:myLabel];
		
		KKLabelNode* otherLabel = [KKLabelNode labelNodeWithFontNamed:@"Arial"];
        otherLabel.text = @"Buttong!";
        otherLabel.fontSize = 30;
        otherLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100);
        [self addChild:otherLabel];
		
		[otherLabel addBehavior:[KKButtonBehavior new] withKey:@"labelbutton2"];
		[self observeNotification:KKButtonDidExecute
						 selector:@selector(otherLabelButtonDidExecute:)
						   object:otherLabel];
	
		/*
		KKSpriteNode* sprite = [KKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(20, 15)];
		//KKSpriteNode* sprite = [KKSpriteNode spriteNodeWithImageNamed:@"crawl-tiles.png"];
		sprite.texture = [SKTexture textureWithImageNamed:@"crawl-tiles-hd.png"];
		[tilemapNode addChild:sprite];
		
		LOG_EXPR(sprite.centerRect);
		 */
		
		SKNode* n1 = [SKNode node];
		[self addChild:n1];
		SKNode* n2 = [SKNode node];
		[n1 addChild:n2];
		SKNode* n3 = [SKNode node];
		[n2 addChild:n3];
		s1 = [KKSpriteNode spriteNodeWithImageNamed:@"Icon.png"];
		s1.position = CGPointMake(300, 100);
		//[self addChild:s1];
		
		[s1 runAction:[SKAction rotateByAngle:M_PI duration:10]];

		KKSpriteNode* s2 = [KKSpriteNode spriteNodeWithImageNamed:@"Icon.png"];
		s2.position = CGPointMake(360, 100);
		s2.anchorPoint = CGPointZero;
		s2.xScale = -1.0;
		//[self addChild:s2];
		
		/*
		for (int i = 0; i < 20; i++)
		{
			KKSpriteNode* s = [KKSpriteNode spriteNodeWithImageNamed:@"Icon.png"];
			[n3 addChild:s];
			if (i == 10)
			{
				KKLabelNode* l = [KKLabelNode labelNodeWithFontNamed:@"Arial"];
				l.text = @"sdölfk";
				[n2 addChild:l];
			}
			
			[n3 addChild:[SKNode node]];
		}
		 */
		
	
		[self createVirtualJoypad];
    }
    return self;
}

-(void) didMoveToView:(SKView *)view
{
	[super didMoveToView:view];
	LOG_EXPR(view.bounds.size);
	[myLabel observe];
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) labelButtonDidExecute:(NSNotification*) note
{
	LOG_EXPR(note);
	SKNode* node = note.object;
	[node removeBehaviorForKey:@"labelbutton1"];
}

-(void) otherLabelButtonDidExecute:(NSNotification*) note
{
	LOG_EXPR(note);
	SKNode* node = note.object;
	[node removeBehaviorForKey:@"labelbutton2"];
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

-(void) createVirtualJoypad
{
	SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:@"Jetpack"];
	
	KKSpriteNode* dpadNode = [KKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Button_DPad_Background.png"]];
	dpadNode.position = CGPointMake(60, 60);
	[dpadNode setScale:0.8];
	[self addChild:dpadNode];
	
	NSArray* dpadTextures = [NSArray arrayWithObjects:
							 [atlas textureNamed:@"Button_DPad_Right_Pressed.png"],
							 [atlas textureNamed:@"Button_DPad_UpRight_Pressed.png"],
							 [atlas textureNamed:@"Button_DPad_Up_Pressed.png"],
							 [atlas textureNamed:@"Button_DPad_UpLeft_Pressed.png"],
							 [atlas textureNamed:@"Button_DPad_Left_Pressed.png"],
							 [atlas textureNamed:@"Button_DPad_DownLeft_Pressed.png"],
							 [atlas textureNamed:@"Button_DPad_Down_Pressed.png"],
							 [atlas textureNamed:@"Button_DPad_DownRight_Pressed.png"],
							 nil];
	KKControlPadBehavior* dpad = [KKControlPadBehavior controlPadBehaviorWithTextures:dpadTextures];
	[dpadNode addBehavior:dpad withKey:@"dpad"];
	
	[self observeNotification:KKControlPadDidChangeDirection
					 selector:@selector(controlPadDidChangeDirection:)
					   object:dpadNode];

	CGSize sceneSize = self.size;

	{
		KKSpriteNode* attackButtonNode = [KKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Button_Attack_NotPressed.png"]];
		attackButtonNode.position = CGPointMake(sceneSize.width - 32, 30);
		[attackButtonNode setScale:0.9];
		[self addChild:attackButtonNode];
		
		KKButtonBehavior* button = [KKButtonBehavior new];
		button.name = @"attack";
		button.selectedTexture = [atlas textureNamed:@"Button_Attack_Pressed.png"];
		[attackButtonNode addBehavior:button];

		[self observeNotification:KKButtonDidExecute
						 selector:@selector(attackButtonPressed:)
						   object:attackButtonNode];
	}
	{
		KKSpriteNode* jetpackButtonNode = [KKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Button_Jetpack_NotPressed.png"]];
		jetpackButtonNode.position = CGPointMake(sceneSize.width - 32, 90);
		[jetpackButtonNode setScale:0.9];
		[self addChild:jetpackButtonNode];
		
		KKButtonBehavior* button = [KKButtonBehavior new];
		button.name = @"jetpack";
		button.selectedTexture = [atlas textureNamed:@"Button_Jetpack_Pressed.png"];
		[jetpackButtonNode addBehavior:button];

		[self observeNotification:KKButtonDidExecute
						 selector:@selector(jetpackButtonPressed:)
						   object:jetpackButtonNode];
	}
}

-(void) controlPadDidChangeDirection:(NSNotification*)note
{
	KKControlPadBehavior* controlPad = [note.userInfo objectForKey:@"behavior"];
	switch (controlPad.direction)
	{
		case KKArcadeJoystickRight:
			NSLog(@"right");
			break;
		case KKArcadeJoystickUpRight:
			NSLog(@"up right");
			break;
		case KKArcadeJoystickUp:
			NSLog(@"up");
			break;
		case KKArcadeJoystickUpLeft:
			NSLog(@"up left");
			break;
		case KKArcadeJoystickLeft:
			NSLog(@"left");
			break;
		case KKArcadeJoystickDownLeft:
			NSLog(@"down left");
			break;
		case KKArcadeJoystickDown:
			NSLog(@"down");
			break;
		case KKArcadeJoystickDownRight:
			NSLog(@"down right");
			break;

		case KKArcadeJoystickNone:
		default:
			NSLog(@"center");
			break;
	}
}

-(void) attackButtonPressed:(NSNotification*)note
{
	NSLog(@"attack!");
}

-(void) jetpackButtonPressed:(NSNotification*)note
{
	NSLog(@"fly! fly!");
}

-(void)update:(NSTimeInterval)currentTime
{
	// calling super will update controllers and behaviors, also advanced frame counter
	[super update:currentTime];
	
	/*
	SKTexture* tex = KKRANDOM_0_1() >= 0.5f ? [SKTexture textureWithImageNamed:@"Icon.png"] : [SKTexture textureWithImageNamed:@"Default.png"];
	s1.texture = tex;
	s1.size = tex.size;
	 */
	
	//LOG_EXPR([self childNodeWithName:@"tilemap"].position);
}

@end
