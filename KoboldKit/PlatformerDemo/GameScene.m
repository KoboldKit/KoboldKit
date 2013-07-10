//
//  MyScene.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "GameScene.h"
#import "MenuScene.h"
#import "PlayerCharacter.h"

@implementation GameScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
	{
        /* Setup your scene here */
		self.backgroundColor = [SKColor colorWithRed:0.1 green:0.5 blue:0.3 alpha:1.0];
		self.anchorPoint = CGPointMake(0.5f, 0.5f);
	
		// hide any ugliness caused by setting up the screen in the first couple frames behind a "curtain" sprite
		_curtainSprite = [KKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:self.size];
		_curtainSprite.zPosition = -1000;
		[self addChild:_curtainSprite];
    }
    return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) didMoveToView:(SKView *)view
{
	// always call super in "event" methods of KKScene subclasses
	[super didMoveToView:view];
	
	_tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:_tmxFile];
	[self addChild:_tilemapNode];
	
	[_tilemapNode createPhysicsCollisions];
	[_tilemapNode createPhysicsCollisionsWithObjectLayerNamed:@"extra-collision"];

	// test write TMX
	[_tilemapNode.tilemap writeToFile:[NSFileManager pathForDocumentsFile:@"testWrite.tmx"]];

	// apply global settings from Tiled
	KKTilemapProperties* mapProperties = _tilemapNode.tilemap.properties;
	self.physicsWorld.gravity = CGPointMake(0, [mapProperties numberForKey:@"physicsGravityY"].floatValue);
	self.physicsWorld.speed = [mapProperties numberForKey:@"physicsSimulationSpeed"].floatValue;
	if (self.physicsWorld.speed == 0.0)
	{
		// compatibility fallback
		self.physicsWorld.speed = [mapProperties numberForKey:@"physicsSpeed"].floatValue;
	}
	LOG_EXPR(self.physicsWorld.gravity);
	LOG_EXPR(self.physicsWorld.speed);

	[self setupPlayerCharacter];
	[self createSimpleControls];
	//[self createVirtualJoypad];
	[self addDevelopmentButtons];
	
	// this must be performed after the player setup, because the player is moving the camera
	if ([mapProperties numberForKey:@"restrictScrollingToMapBoundary"].boolValue)
	{
		[_tilemapNode restrictScrollingToMapBoundary];
	}

	// remove the curtain
	[_curtainSprite runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:0.5], [SKAction removeFromParent]]]];
	_curtainSprite = nil;
}

-(void) addDevelopmentButtons
{
#if DEBUG
	KKViewOriginNode* hudNode = [KKViewOriginNode node];
	[self addChild:hudNode];
	
	KKLabelNode* reloadLabel = [KKLabelNode labelNodeWithFontNamed:@"Arial"];
	reloadLabel.name = @"reload label";
	reloadLabel.text = @"reload";
	reloadLabel.color = [SKColor blueColor];
	reloadLabel.colorBlendFactor = 0.6;
	reloadLabel.position = CGPointMake(self.size.width / 2, self.size.height - reloadLabel.fontSize * 1.5);
	[hudNode addChild:reloadLabel];
	
	[reloadLabel addBehavior:[KKButtonBehavior behavior]];
	[self observeNotification:KKButtonDidExecuteNotification selector:@selector(reloadButtonPressed:) object:reloadLabel];

	KKLabelNode* menuLabel = [KKLabelNode labelNodeWithFontNamed:@"Arial"];
	menuLabel.name = @"reload label";
	menuLabel.text = @"menu";
	menuLabel.color = [SKColor blueColor];
	menuLabel.colorBlendFactor = 0.4;
	menuLabel.position = CGPointMake(self.size.width / 4, self.size.height - reloadLabel.fontSize * 1.5);
	[hudNode addChild:menuLabel];
	
	[menuLabel addBehavior:[KKButtonBehavior behavior]];
	[self observeNotification:KKButtonDidExecuteNotification selector:@selector(menuButtonPressed:) object:menuLabel];
#endif
}

-(void) reloadButtonPressed:(NSNotification*)notification
{
	[self enumerateChildNodesWithName:@"//reload label" usingBlock:^(SKNode *node, BOOL *stop) {
		[node removeFromParent];
	}];
	
	_curtainSprite = [KKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:self.size];
	_curtainSprite.zPosition = -1000;
	[self addChild:_curtainSprite];
	
	SKLabelNode* loadingLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
	loadingLabel.text = @"Loading...";
	loadingLabel.fontSize = loadingLabel.fontSize * 2;
	loadingLabel.color = [SKColor purpleColor];
	loadingLabel.colorBlendFactor = 0.5;
	[_curtainSprite addChild:loadingLabel];

	// Transfers all changed resource files from the remote server to the specified folder in the app support directory
	NSString* url = [self.kkView.model valueForKeyPath:@"devconfig.developmentWebServerURL"];
	[KKDownloadProjectFiles downloadProjectFilesWithURL:[NSURL URLWithString:url]
										completionBlock:^(NSDictionary *contents) {
											[self.kkView reloadConfig];
											
											GameScene* newScene = [GameScene sceneWithSize:self.size];
											newScene.tmxFile = _tmxFile;
											[self.view presentScene:newScene];
										}];
}

-(void) menuButtonPressed:(NSNotification*)notification
{
	MenuScene* newScene = [MenuScene sceneWithSize:self.size];
	[self.view presentScene:newScene];
}

-(void) setupPlayerCharacter
{
	KKTilemapObject* playerObject = [[_tilemapNode.tilemap layerNamed:@"game objects"] objectNamed:@"player"];
	NSAssert(playerObject, @"No object named 'player' on tilemap!");
	
	_playerCharacter = [PlayerCharacter node];
	[_tilemapNode.mainTileLayerNode addChild:_playerCharacter];
	[_playerCharacter setupWithPlayerObject:playerObject movementBounds:_tilemapNode.bounds];
}

-(void) createVirtualJoypad
{
	KKViewOriginNode* joypadNode = [KKViewOriginNode node];
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

	CGSize sceneSize = self.size;
	KKSpriteNode* attackButtonNode = [KKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Button_Attack_NotPressed.png"]];
	attackButtonNode.position = CGPointMake(sceneSize.width - 32, 30);
	[attackButtonNode setScale:0.9];
	[joypadNode addChild:attackButtonNode];
	{
		KKButtonBehavior* button = [KKButtonBehavior new];
		button.name = @"attack";
		button.selectedTexture = [atlas textureNamed:@"Button_Attack_Pressed.png"];
		button.executesWhenPressed = YES;
		[attackButtonNode addBehavior:button];
	}

	KKSpriteNode* jumpButtonNode = [KKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Button_Jetpack_NotPressed.png"]];
	jumpButtonNode.position = CGPointMake(sceneSize.width - 32, 90);
	[jumpButtonNode setScale:0.9];
	[joypadNode addChild:jumpButtonNode];
	{
		KKButtonBehavior* button = [KKButtonBehavior new];
		button.name = @"jetpack";
		button.selectedTexture = [atlas textureNamed:@"Button_Jetpack_Pressed.png"];
		button.executesWhenPressed = YES;
		[jumpButtonNode addBehavior:button];
	}

	// make player observe joypad
	[_playerCharacter observeNotification:KKControlPadDidChangeDirectionNotification
								 selector:@selector(controlPadDidChangeDirection:)
								   object:dpadNode];
	[_playerCharacter observeNotification:KKButtonDidExecuteNotification
								 selector:@selector(jumpButtonPressed:)
								   object:jumpButtonNode];
	[_playerCharacter observeNotification:KKButtonDidExecuteNotification
								 selector:@selector(attackButtonPressed:)
								   object:attackButtonNode];
}

-(void) createSimpleControls
{
	KKViewOriginNode* joypadNode = [KKViewOriginNode node];
	[self addChild:joypadNode];

	SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:@"Jetpack"];

	KKSpriteNode* dpadNode = [KKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"button_directions_background"]];
	dpadNode.position = CGPointMake(dpadNode.size.width / 2 + 10, dpadNode.size.height / 2 + 10);
	[joypadNode addChild:dpadNode];
	
	NSArray* dpadTextures = [NSArray arrayWithObjects:
							 [atlas textureNamed:@"button_directions_right"],
							 [atlas textureNamed:@"button_directions_left"],
							 nil];
	KKControlPadBehavior* dpad = [KKControlPadBehavior controlPadBehaviorWithTextures:dpadTextures];
	[dpadNode addBehavior:dpad withKey:@"simple dpad"];


	CGSize sceneSize = self.size;
	KKSpriteNode* jumpButtonNode = [KKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"button_jump_notpressed"]];
	jumpButtonNode.position = CGPointMake(sceneSize.width - (jumpButtonNode.size.width / 2 + 10), jumpButtonNode.size.height / 2 + 10);
	[joypadNode addChild:jumpButtonNode];
	
	KKButtonBehavior* button = [KKButtonBehavior new];
	button.name = @"jump";
	button.selectedTexture = [atlas textureNamed:@"button_jump_pressed"];
	button.executesWhenPressed = YES;
	[jumpButtonNode addBehavior:button];
	
	// make player observe joypad
	[_playerCharacter observeNotification:KKControlPadDidChangeDirectionNotification
								 selector:@selector(controlPadDidChangeDirection:)
								   object:dpadNode];
	[_playerCharacter observeNotification:KKButtonDidExecuteNotification
								 selector:@selector(jumpButtonPressed:)
								   object:jumpButtonNode];
}

-(void) testCollision:(SKPhysicsContact *)contact
{
	SKPhysicsBody* playerPhysicsBody = _playerCharacter.physicsBody;
	if (contact.bodyA == playerPhysicsBody || contact.bodyB == playerPhysicsBody)
	{
		//playerPhysicsBody.velocity = CGPointZero;
		
		SKPhysicsWorld* physicsWorld = self.physicsWorld;
		CGPoint playerPosition = _playerCharacter.position;
		CGSize playerSize = [_playerCharacter calculateAccumulatedFrame].size;
		CGPoint playerAnchorPoint = CGPointMake(0.5, 0.5);
		//CGPoint rayStart, rayEnd;
		
		/*
		 rayStart = CGPointMake(playerPosition.x - playerSize.width * playerAnchorPoint.x,
		 playerPosition.y + 8 + playerSize.height * (1.0 - playerAnchorPoint.y));
		 */
		rayStart = CGPointMake(playerPosition.x - playerSize.width * playerAnchorPoint.x,
							   playerPosition.y - (8 + playerSize.height * playerAnchorPoint.y));
		rayEnd = CGPointMake(playerPosition.x + playerSize.width * (1.0 - playerAnchorPoint.x),
							 rayStart.y);
		
		//NSLog(@"ray: %@ to %@", NSStringFromCGPoint(rayStart), NSStringFromCGPoint(rayEnd));
		
		[self enumerateChildNodesWithName:@"test" usingBlock:^(SKNode *node, BOOL *stop) {
			[node removeFromParent];
		}];
		[_playerCharacter enumerateChildNodesWithName:@"test" usingBlock:^(SKNode *node, BOOL *stop) {
			[node removeFromParent];
		}];
		
		{
			SKSpriteNode* test = [SKSpriteNode spriteNodeWithColor:[SKColor magentaColor] size:CGSizeMake(5, 5)];
			test.name = @"test";
			test.position = [_playerCharacter convertPoint:rayStart fromNode:_playerCharacter.parent];
			test.zPosition = -9999;
			[_playerCharacter addChild:test];
			
			SKSpriteNode* test2 = [SKSpriteNode spriteNodeWithColor:[SKColor magentaColor] size:CGSizeMake(5, 5)];
			test2.name = @"test";
			test2.position = [_playerCharacter convertPoint:rayEnd fromNode:_playerCharacter.parent];
			test2.zPosition = -9999;
			[_playerCharacter addChild:test2];
		}
		
		/*
		 rayStart = [self convertPoint:rayStart fromNode:_playerCharacter.parent];
		 rayEnd = [self convertPoint:rayEnd fromNode:_playerCharacter.parent];
		 rayStart = ccpMult(rayStart, -1.0);
		 rayEnd = ccpMult(rayEnd, -1.0);
		 */
		//LOG_EXPR(rayStart);
		
		{
			/*
			 SKSpriteNode* test = [SKSpriteNode spriteNodeWithColor:[SKColor yellowColor] size:CGSizeMake(5, 5)];
			 test.name = @"test";
			 test.position = rayStart;
			 test.zPosition = -9999;
			 [self addChild:test];
			 
			 SKSpriteNode* test2 = [SKSpriteNode spriteNodeWithColor:[SKColor yellowColor] size:CGSizeMake(5, 5)];
			 test2.name = @"test";
			 test2.position = rayEnd;
			 test2.zPosition = -9999;
			 [self addChild:test2];
			 */
		}
		
		SKPhysicsBody* bodyAbove = [physicsWorld bodyAlongRayStart:rayStart end:rayEnd];
		//SKPhysicsBody* bodyAbove = [physicsWorld bodyInRect:_playerCharacter.frame];
		if (bodyAbove)
		{
			//LOG_EXPR(bodyAbove);
			//NSAssert(bodyAbove != playerPhysicsBody, @"!");
		}
	}
}

/*
-(void) didBeginContact:(SKPhysicsContact *)contact
{
	[super didBeginContact:contact];

	//[self testCollision:contact];
}
 */

/*
-(void) didEndContact:(SKPhysicsContact *)contact
{
	[super didEndContact:contact];
	NSLog(@"did END Contact: %@", contact);

	[_physicsContactDebugNode removeContact:contact];
}
*/

@end
