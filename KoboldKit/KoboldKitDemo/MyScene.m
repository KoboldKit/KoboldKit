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
		
		//KKTilemapNode* tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:@"crawl-tilemap.tmx"];
		KKTilemapNode* tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:@"forest-parallax.tmx"];
		[self addChild:tilemapNode];
		tilemapNode.name = @"tilemap";
		
		//tilemapNode.xScale = 0.7f;
		//tilemapNode.yScale = 0.7f;
		//[tilemapNode.mainTileLayerNode runAction:[SKAction scaleTo:2.0f duration:20]];
		tilemapNode.mainTileLayerNode.position = CGPointMake(0, -110);
		[tilemapNode.mainTileLayerNode runAction:[SKAction moveByX:-10500 y:0 duration:120]];
		
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
	
	/*
	SKTexture* tex = KKRANDOM_0_1() >= 0.5f ? [SKTexture textureWithImageNamed:@"Icon.png"] : [SKTexture textureWithImageNamed:@"Default.png"];
	s1.texture = tex;
	s1.size = tex.size;
	 */
	
	//LOG_EXPR([self childNodeWithName:@"tilemap"].position);
}

@end
