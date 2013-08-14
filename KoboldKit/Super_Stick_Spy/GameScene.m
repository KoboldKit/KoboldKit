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
        // camera follow requires scene's anchorPoint at the center of the screen
		self.anchorPoint = CGPointMake(0.5f, 0.5f);
	
		// hide screen in the first couple frames behind a "curtain" sprite since it takes a few frames for the scene to be fully set up
		_curtainSprite = [KKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:self.size];
		_curtainSprite.zPosition = 1000;
		[self addChild:_curtainSprite];
		
		[self playSoundFileNamed:@"teleport.wav"];
		
		/*
		SKAction* jingle = [SKAction playSoundFileNamed:@"Time to business, guys.mp3" waitForCompletion:YES];
		SKAction* loop = [SKAction runBlock:^{
			[[SKTAudio sharedInstance] playBackgroundMusic:@"WeltHerrschererTheme1.mp3"];
		}];
		[self runAction:[SKAction sequence:@[jingle, loop]]];
		*/
    }
    return self;
}

-(void) didMoveToView:(SKView *)view
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMapNotification:) name:@"LoadMap" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidStepInDeadlyTrap:) name:@"DeadlyTrap" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkpointActivated:) name:@"CheckpointActivated" object:nil];
	
	// always call super in "event" methods of KKScene subclasses
	[super didMoveToView:view];
	
	_tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:_tmxFile];
	[self addChild:_tilemapNode];
	
	[_tilemapNode createPhysicsShapesWithTileLayerNode:_tilemapNode.mainTileLayerNode];
	[_tilemapNode createPhysicsShapesWithObjectLayerNode:[_tilemapNode objectLayerNodeNamed:@"extra-collision"]];
	
	// test write TMX
	[_tilemapNode.tilemap writeToFile:[NSBundle pathForDocumentsFile:@"testWrite.tmx"]];
	
	// apply global settings from Tiled
	KKTilemapProperties* mapProperties = _tilemapNode.tilemap.properties;
	self.physicsWorld.gravity = CGPointMake(0, [mapProperties numberForKey:@"physicsGravityY"].floatValue);
	self.physicsWorld.speed = [mapProperties numberForKey:@"physicsSimulationSpeed"].floatValue;
	if (self.physicsWorld.speed == 0.0)
	{
		// compatibility fallback
		self.physicsWorld.speed = [mapProperties numberForKey:@"physicsSpeed"].floatValue;
	}
	
	[_tilemapNode spawnObjects];
	
	_playerCharacter = (PlayerCharacter*)[_tilemapNode.gameObjectsLayerNode childNodeWithName:@"player"];
	NSAssert1([_playerCharacter isKindOfClass:[PlayerCharacter class]], @"player node (%@) is not of class PlayerCharacter!", _playerCharacter);
	
	if (_spawnAtCheckpoint.length)
	{
		KKTilemapObject* object = [_tilemapNode objectNamed:_spawnAtCheckpoint];
		[_playerCharacter setCheckpoint:object];
		[_playerCharacter moveToCheckpoint];
	}
	
	[self createSimpleControls];
	
	// this must be performed after the player setup, because the player is moving the camera
	if ([mapProperties numberForKey:@"restrictScrollingToMapBoundary"].boolValue)
	{
		[_tilemapNode restrictScrollingToMapBoundary];
	}
	[_tilemapNode enableParallaxScrolling];
	
	// remove the curtain
	[_curtainSprite runAction:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction fadeAlphaTo:0 duration:0.5], [SKAction removeFromParent]]]];
	_curtainSprite = nil;

	
	// debug only
	[self addDevelopmentButtons];
}

-(void) loadMapNotification:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadMap" object:nil];

	NSString* checkpoint = notification.userInfo[@"checkpoint"];
	NSString* tmxFile = notification.userInfo[@"tmxFile"];
	NSAssert1(tmxFile.length, @"LoadMap notification is missing the info.tmxFile property! Sender: %@", notification.object);
	
	GameScene* newScene = [GameScene sceneWithSize:self.size];
	newScene.tmxFile = tmxFile;
	newScene.spawnAtCheckpoint = checkpoint;
	[self.scene.view presentScene:newScene transition:[SKTransition fadeWithColor:[SKColor grayColor] duration:0.5]];
}

-(void) playerDidStepInDeadlyTrap:(NSNotification*)notification
{
	[_playerCharacter die];
}

-(void) checkpointActivated:(NSNotification*)notification
{
	KKTilemapObject* checkpoint = [_tilemapNode objectNamed:((SKNode*)notification.object).name];
	[_playerCharacter setCheckpoint:checkpoint];
}

-(void) createSimpleControls
{
	KKViewOriginNode* joypadNode = [KKViewOriginNode node];
	joypadNode.name = @"joypad";
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





#pragma mark CODE BELOW WILL NOT BE DISCUSSED IN BOOK; WILL BE REMOVED!


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
	_curtainSprite.zPosition = 1000;
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

@end
