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
	
	_tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:_tmxFile];
	[self addChild:_tilemapNode];
	
	// test write TMX
	[_tilemapNode.tilemap writeToFile:[NSFileManager pathForDocumentsFile:@"testWrite.tmx"]];
	
	// apply global settings from Tiled
	KKTilemapProperties* mapProperties = _tilemapNode.tilemap.properties;
	self.physicsWorld.gravity = CGPointMake(0, [mapProperties numberForKey:@"physicsGravityY"].floatValue);
	self.physicsWorld.speed = [mapProperties numberForKey:@"physicsSpeed"].floatValue;
	LOG_EXPR(self.physicsWorld.gravity);
	LOG_EXPR(self.physicsWorld.speed);
	
	[self setupTilemapBlocking];
	[self setupPlayerCharacter];
	[self createSimpleControls];
	//[self createVirtualJoypad];
	[self addReloadButton];
	
	if ([mapProperties numberForKey:@"restrictScrollingToMapBoundary"].boolValue)
	{
		[_tilemapNode restrictScrollingToMapBoundary];
	}

	
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
	
	CGSize bboxSize = playerSize;
	bboxSize.width -= 6;
	bboxSize.height -= 6;
	[_playerCharacter physicsBodyWithRectangleOfSize:bboxSize];
	_playerCharacter.physicsBody.contactTestBitMask = 0xFFFFFFFF;
	_playerCharacter.name = @"player";
	_playerCharacter.position = playerPosition;
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
	[_tilemapNode createPhysicsCollisions];
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

	/*
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
	 */
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

-(void) testCollision:(SKPhysicsContact *)contact
{
	SKPhysicsBody* playerPhysicsBody = _playerCharacter.physicsBody;
	if (contact.bodyA == playerPhysicsBody || contact.bodyB == playerPhysicsBody)
	{
		//playerPhysicsBody.velocity = CGPointZero;
		
		SKPhysicsWorld* physicsWorld = self.physicsWorld;
		CGPoint playerPosition = _playerCharacter.position;
		CGSize playerSize = _playerCharacter.size;
		CGPoint playerAnchorPoint = _playerCharacter.anchorPoint;
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

-(void)update:(NSTimeInterval)currentTime
{
	// always call superr in "event" methods of KKScene subclasses
	[super update:currentTime];
	
	//_playerCharacter.position = ccpAdd(_playerCharacter.position, _currentControlPadDirection);
	[_playerCharacter.physicsBody applyForce:_currentControlPadDirection];
	
	//NSLog(@"pos: {%.0f, %.0f}", _playerCharacter.position.x, _playerCharacter.position.y);
	//NSLog(@"pos: {%.0f, %.0f}", _tilemapNode.mainTileLayerNode.position.x, _tilemapNode.mainTileLayerNode.position.y);

	/*
	if (CGPointEqualToPoint(rayStart, rayEnd) == NO)
	{
		//SKPhysicsBody* body = [self.physicsWorld bodyAlongRayStart:rayStart end:rayEnd];
		SKPhysicsBody* body = [self.physicsWorld bodyAlongRayStart:CGPointMake(288, 188) end:CGPointMake(310, 220)];
		if (body)
		{
			LOG_EXPR(body);
		}
	}
	*/
	
	//LOG_EXPR(_playerCharacter.position);
}

-(void) didSimulatePhysics
{
	// always call superr in "event" methods of KKScene subclasses
	[super didSimulatePhysics];
	
	//LOG_EXPR(_tilemapNode.position);
}

@end
