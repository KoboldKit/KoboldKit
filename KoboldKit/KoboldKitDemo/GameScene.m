//
//  MyScene.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "GameScene.h"
#import "KoboldKit.h"

#import <objc/runtime.h>

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
	
	self.view.showsDrawCount = NO;
	self.view.showsFPS = NO;
	self.view.showsNodeCount = NO;

	_tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:_tmxFile];
	[self addChild:_tilemapNode];
	
	// apply gravity from Tiled
	self.physicsWorld.gravity = CGPointMake(0, [_tilemapNode.tilemap.properties numberForKey:@"physicsGravityY"].floatValue);
	self.physicsWorld.speed = [_tilemapNode.tilemap.properties numberForKey:@"physicsSpeed"].floatValue;
	LOG_EXPR(self.physicsWorld.gravity);
	LOG_EXPR(self.physicsWorld.speed);
	
	[self setupTilemapBlocking];
	
	if ([_tilemapNode.tilemap.properties numberForKey:@"restrictScrollingToMapBoundary"].boolValue)
	{
		[_tilemapNode restrictScrollingToMapBoundary];
	}
	
	_physicsContactDebugNode = [KKPhysicsDebugNode node];
	[_tilemapNode.mainTileLayerNode addChild:_physicsContactDebugNode];
	
	[self setupPlayerCharacter];
	
	[self createSimpleControls];
	//[self createVirtualJoypad];

	[self addReloadButton];
	
	// remove the curtain
	[_curtainSprite runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:0.5], [SKAction removeFromParent]]]];
	_curtainSprite = nil;
}

-(void) addReloadButton
{
#if DEBUG
	KKViewOriginNode* hudNode = [KKViewOriginNode node];
	[self addChild:hudNode];
	
	KKLabelNode* reloadLabel = [KKLabelNode labelNodeWithFontNamed:@"Arial"];
	reloadLabel.name = @"reload label";
	reloadLabel.text = @"reload";
	reloadLabel.position = CGPointMake(self.size.width / 2, self.size.height - reloadLabel.fontSize * 1.5);
	[hudNode addChild:reloadLabel];
	
	[reloadLabel addBehavior:[KKButtonBehavior behavior]];
	[self observeNotification:KKButtonDidExecuteNotification selector:@selector(reloadButtonPressed:) object:reloadLabel];
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

-(void) setupPlayerCharacter
{
	KKTilemapObject* playerObject;
	for (KKTilemapObject* object in [_tilemapNode.tilemap layerNamed:@"game objects"].objects)
	{
		if ([object.name isEqualToString:@"player"])
		{
			playerObject = object;
			break;
		}
	}

	CGSize playerSize = playerObject.size;
	CGPoint playerPosition = CGPointMake(playerObject.position.x + playerSize.width / 2,
										 playerObject.position.y + playerSize.height / 2);

	KKTilemapProperties* playerProperties = playerObject.properties;
	NSString* defaultImage = [playerProperties stringForKey:@"defaultImage"];
	if (defaultImage.length > 0)
	{
		_playerCharacter = [KKSpriteNode spriteNodeWithImageNamed:defaultImage];
		playerSize = _playerCharacter.size;
	}
	else
	{
		_playerCharacter = [KKSpriteNode spriteNodeWithColor:[UIColor redColor] size:playerSize];
	}
	
	_playerCharacter.position = playerPosition;
	[_playerCharacter physicsBodyWithRectangleOfSize:playerSize];
	_playerCharacter.physicsBody.contactTestBitMask = 0xFFFFFFFF;
	[_tilemapNode.mainTileLayerNode addChild:_playerCharacter];
	

	_playerCharacter.physicsBody.allowsRotation = [playerProperties numberForKey:@"allowsRotation"].boolValue;
	_playerCharacter.physicsBody.angularDamping = [playerProperties numberForKey:@"angularDamping"].floatValue;
	_playerCharacter.physicsBody.linearDamping = [playerProperties numberForKey:@"linearDamping"].floatValue;
	_playerCharacter.physicsBody.friction = [playerProperties numberForKey:@"friction"].floatValue;
	_playerCharacter.physicsBody.mass = [playerProperties numberForKey:@"mass"].floatValue;
	_playerCharacter.physicsBody.restitution = [playerProperties numberForKey:@"restitution"].floatValue;
	_jumpForce = [playerProperties numberForKey:@"jumpForce"].floatValue;
	_dpadForce = [playerProperties numberForKey:@"dpadForce"].floatValue;
	LOG_EXPR(_playerCharacter.physicsBody.allowsRotation);
	LOG_EXPR(_playerCharacter.physicsBody.angularDamping);
	LOG_EXPR(_playerCharacter.physicsBody.linearDamping);
	LOG_EXPR(_playerCharacter.physicsBody.friction);
	LOG_EXPR(_playerCharacter.physicsBody.mass);
	LOG_EXPR(_playerCharacter.physicsBody.density);
	LOG_EXPR(_playerCharacter.physicsBody.restitution);
	LOG_EXPR(_playerCharacter.physicsBody.area);
	LOG_EXPR(_jumpForce);
	LOG_EXPR(_dpadForce);

	// limit maximum speed of the player
	if ([playerProperties numberForKey:@"velocityLimit"])
	{
		CGFloat limit = [playerProperties numberForKey:@"velocityLimit"].doubleValue;
		[_playerCharacter addBehavior:[KKLimitVelocityBehavior limitVelocity:limit]];
	}
	
	// prevent player from leaving the area
	if ([playerProperties numberForKey:@"stayInBounds"].boolValue)
	{
		[_playerCharacter addBehavior:[KKStayInBoundsBehavior stayInBounds:_tilemapNode.bounds]];
	}

	// make the camera follow the player
	[_playerCharacter addBehavior:[KKCameraFollowBehavior new] withKey:@"camera"];
}

-(void) setupTilemapBlocking
{
	KKIntegerArray* blockingGids = [KKIntegerArray integerArrayWithCapacity:32];
	for (KKTilemapTileset* tileset in _tilemapNode.tilemap.tilesets)
	{
		NSString* blockingTiles = [tileset.properties stringForKey:@"blockingTiles"];
		if (blockingTiles.length)
		{
			NSArray* components = [blockingTiles componentsSeparatedByString:@","];
			for (NSString* range in components)
			{
				NSUInteger gidStart = 0, gidEnd = 0;
				NSArray* fromTo = [range componentsSeparatedByString:@"-"];
				if (fromTo.count == 1)
				{
					gidStart = [[fromTo firstObject] intValue];
					gidEnd = gidStart;
				}
				else
				{
					gidStart = [[fromTo firstObject] intValue];
					gidEnd = [[fromTo lastObject] intValue];
				}

				for (NSUInteger i = gidStart; i <= gidEnd; i++)
				{
					[blockingGids addInteger:i + tileset.firstGid - 1];
				}
			}
		}
	}

	LOG_EXPR(blockingGids);
	[_tilemapNode createPhysicsCollisionsWithBlockingGids:blockingGids];
	[_tilemapNode createPhysicsCollisionsWithObjectLayerNamed:@"extra-collision"];
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
	
	[self observeNotification:KKControlPadDidChangeDirectionNotification
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
		button.executesWhenPressed = YES;
		[attackButtonNode addBehavior:button];

		[self observeNotification:KKButtonDidExecuteNotification
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
		button.executesWhenPressed = YES;
		[jetpackButtonNode addBehavior:button];

		[self observeNotification:KKButtonDidExecuteNotification
						 selector:@selector(jumpButtonPressed:)
						   object:jetpackButtonNode];
	}
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
	
	[self observeNotification:KKControlPadDidChangeDirectionNotification
					 selector:@selector(controlPadDidChangeDirection:)
					   object:dpadNode];


	CGSize sceneSize = self.size;
	{
		KKSpriteNode* jumpButtonNode = [KKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"button_jump_notpressed"]];
		jumpButtonNode.position = CGPointMake(sceneSize.width - (jumpButtonNode.size.width / 2 + 10), jumpButtonNode.size.height / 2 + 10);
		[joypadNode addChild:jumpButtonNode];
		
		KKButtonBehavior* button = [KKButtonBehavior new];
		button.name = @"jump";
		button.selectedTexture = [atlas textureNamed:@"button_jump_pressed"];
		button.executesWhenPressed = YES;
		[jumpButtonNode addBehavior:button];
		
		[self observeNotification:KKButtonDidExecuteNotification
						 selector:@selector(jumpButtonPressed:)
						   object:jumpButtonNode];
	}
}

-(void) controlPadDidChangeDirection:(NSNotification*)note
{
	KKControlPadBehavior* controlPad = [note.userInfo objectForKey:@"behavior"];
	
	_currentControlPadDirection = ccpMult(vectorFromJoystickState(controlPad.direction), _dpadForce);

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

-(void) jumpButtonPressed:(NSNotification*)note
{
	CGPoint velocity = _playerCharacter.physicsBody.velocity;
	if (velocity.y <= 0)
	{
		velocity.y = 0;
		_playerCharacter.physicsBody.velocity = velocity;
		[_playerCharacter.physicsBody applyImpulse:CGPointMake(0, _jumpForce)];
	}
}

-(void) didBeginContact:(SKPhysicsContact *)contact
{
	[super didBeginContact:contact];
	NSLog(@"did Begin Contact: %@", contact);
	/*
	LOG_EXPR(contact.bodyA);
	LOG_EXPR(contact.bodyB);
	LOG_EXPR(contact.contactPoint);
	 */
	
	[_physicsContactDebugNode addContact:contact];
}

-(void) didEndContact:(SKPhysicsContact *)contact
{
	[super didEndContact:contact];
	NSLog(@"did END Contact: %@", contact);

	[_physicsContactDebugNode removeContact:contact];
}

-(void)update:(NSTimeInterval)currentTime
{
	// always call superr in "event" methods of KKScene subclasses
	[super update:currentTime];
	
	//_playerCharacter.position = ccpAdd(_playerCharacter.position, _currentControlPadDirection);
	[_playerCharacter.physicsBody applyForce:_currentControlPadDirection];
	
	//NSLog(@"pos: {%.0f, %.0f}", _playerCharacter.position.x, _playerCharacter.position.y);
	//NSLog(@"pos: {%.0f, %.0f}", _tilemapNode.mainTileLayerNode.position.x, _tilemapNode.mainTileLayerNode.position.y);
}

-(void) didSimulatePhysics
{
	// always call superr in "event" methods of KKScene subclasses
	[super didSimulatePhysics];
	
	//LOG_EXPR(_tilemapNode.position);
}

@end
