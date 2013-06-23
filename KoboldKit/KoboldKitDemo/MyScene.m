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
		LOG_EXPR(self.frame);
		LOG_EXPR(self.size);
		
        /* Setup your scene here */
		self.anchorPoint = CGPointMake(0.5f, 0.5f);
		self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];

		_tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:@"crawl-tilemap.tmx"];
		//KKTilemapNode* tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:@"forest-parallax.tmx"];
		[self addChild:_tilemapNode];
		_tilemapNode.name = @"tilemap";

		_testCamera = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(20, 20)];
		_testCamera.position = CGPointMake(70, 90);
		[_tilemapNode addChild:_testCamera];
		
		[_testCamera addBehavior:[KKCameraFollowBehavior new] withKey:@"camera"];
		[_testCamera addBehavior:[KKStayInBoundsBehavior stayInBounds:_tilemapNode.bounds]];
		
		LOG_EXPR(_tilemapNode.bounds);
		CGRect bounds = _tilemapNode.bounds;
		bounds.origin = [self convertPoint:bounds.origin fromNode:_tilemapNode];
		LOG_EXPR(bounds);
		
		bounds.origin.x = -(bounds.size.width + 0);
		bounds.origin.y = -(bounds.size.height + 0);
		bounds.size.width = bounds.size.width - 120;
		bounds.size.height = bounds.size.height - 80;
		LOG_EXPR(bounds);
		[_tilemapNode addBehavior:[KKStayInBoundsBehavior stayInBounds:bounds]];
		
		[self createVirtualJoypad];
    }
    return self;
}

-(void) didMoveToView:(SKView *)view
{
	// always call superr in "event" methods of KKScene subclasses
	[super didMoveToView:view];
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
	SKNode* joypadNode = [SKNode node];
	joypadNode.position = self.scene.frame.origin;
	[self addChild:joypadNode];
	
	SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:@"Jetpack"];
	
	KKSpriteNode* dpadNode = [KKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Button_DPad_Background.png"]];
	dpadNode.position = CGPointMake(60, 60);
	[dpadNode setScale:0.8];
	[joypadNode addChild:dpadNode];
	
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
		[joypadNode addChild:attackButtonNode];
		
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
		[joypadNode addChild:jetpackButtonNode];
		
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
	
	_currentControlPadDirection = ccpMult(vectorFromJoystickState(controlPad.direction), 3);

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
	// always call superr in "event" methods of KKScene subclasses
	[super update:currentTime];
	
	_testCamera.position = ccpAdd(_testCamera.position, _currentControlPadDirection);
}

-(void) didSimulatePhysics
{
	// always call superr in "event" methods of KKScene subclasses
	[super didSimulatePhysics];
	
	//LOG_EXPR(_tilemapNode.position);
}

@end
