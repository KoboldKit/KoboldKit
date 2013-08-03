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

-(id) initWithSize:(CGSize)size
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

-(void) loadMapNotification:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadMap" object:nil];

	GameScene* newScene = [GameScene sceneWithSize:self.size];
	newScene.tmxFile = ((SKNode*)notification.object).name;
	[self.scene.view presentScene:newScene transition:[SKTransition fadeWithColor:[SKColor grayColor] duration:0.5]];
}

-(void) didMoveToView:(SKView *)view
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMapNotification:) name:@"LoadMap" object:nil];

	// always call super in "event" methods of KKScene subclasses
	[super didMoveToView:view];
	
	_tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:_tmxFile];
	[self addChild:_tilemapNode];
	
	[_tilemapNode createPhysicsShapesWithTileLayerNode:_tilemapNode.mainTileLayerNode];
	[_tilemapNode createPhysicsShapesWithObjectLayerNode:[_tilemapNode objectLayerNodeNamed:@"extra-collision"]];

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

	[_tilemapNode spawnObjects];
	
	_playerCharacter = (PlayerCharacter*)[_tilemapNode.gameObjectsLayerNode childNodeWithName:@"player"];
	NSAssert1([_playerCharacter isKindOfClass:[PlayerCharacter class]], @"player node (%@) is not of class PlayerCharacter!", _playerCharacter);
	
	[self createSimpleControls];
	//[self createVirtualJoypad];
	[self addDevelopmentButtons];
	
	// this must be performed after the player setup, because the player is moving the camera
	if ([mapProperties numberForKey:@"restrictScrollingToMapBoundary"].boolValue)
	{
		[_tilemapNode restrictScrollingToMapBoundary];
	}
	[_tilemapNode enableParallaxScrolling];

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

/*
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
	[_playerCharacter observeNotification:KKButtonDidEndExecuteNotification
								 selector:@selector(jumpButtonReleased:)
								   object:jumpButtonNode];
	[_playerCharacter observeNotification:KKButtonDidExecuteNotification
								 selector:@selector(attackButtonPressed:)
								   object:attackButtonNode];
}
*/

-(void) createSimpleControls
{
	KKViewOriginNode* joypadNode = [KKViewOriginNode node];
	[self addChild:joypadNode];

	SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:@"Jetpack"];

	KKSpriteNode* dpadNode = [KKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"button_directions_background"]];
	dpadNode.position = CGPointMake(dpadNode.size.width / 2 + 15, dpadNode.size.height / 2 + 15);
	[joypadNode addChild:dpadNode];
	
	NSArray* dpadTextures = [NSArray arrayWithObjects:
							 [atlas textureNamed:@"button_directions_right"],
							 [atlas textureNamed:@"button_directions_left"],
							 nil];
	KKControlPadBehavior* dpad = [KKControlPadBehavior controlPadBehaviorWithTextures:dpadTextures];
	[dpadNode addBehavior:dpad withKey:@"simple dpad"];

	dpad.deadZone = 0;

	CGSize sceneSize = self.size;
	KKSpriteNode* jumpButtonNode = [KKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"button_jump_notpressed"]];
	jumpButtonNode.position = CGPointMake(sceneSize.width - (jumpButtonNode.size.width / 2 + 20), jumpButtonNode.size.height / 2 + 20);
	[joypadNode addChild:jumpButtonNode];
	
	KKButtonBehavior* button = [KKButtonBehavior new];
	button.name = @"jump";
	button.selectedTexture = [atlas textureNamed:@"button_jump_pressed"];
	button.executesWhenPressed = YES;
	button.selectedScale = 1.0;
	[jumpButtonNode addBehavior:button];
	
	// make player observe joypad
	[_playerCharacter observeNotification:KKControlPadDidChangeDirectionNotification
								 selector:@selector(controlPadDidChangeDirection:)
								   object:dpadNode];
	[_playerCharacter observeNotification:KKButtonDidExecuteNotification
								 selector:@selector(jumpButtonPressed:)
								   object:jumpButtonNode];
	[_playerCharacter observeNotification:KKButtonDidEndExecuteNotification
								 selector:@selector(jumpButtonReleased:)
								   object:jumpButtonNode];
}

@end
