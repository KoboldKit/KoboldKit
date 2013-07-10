//
//  PlayerCharacter.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 10.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "PlayerCharacter.h"

@implementation PlayerCharacter

-(void) setupWithPlayerObject:(KKTilemapObject*)playerObject movementBounds:(CGRect)movementBounds
{
	CGSize playerSize = playerObject.size;
	CGPoint playerPosition = CGPointMake(playerObject.position.x + playerSize.width / 2,
										 playerObject.position.y + playerSize.height / 2);
	
	KKTilemapProperties* playerProperties = playerObject.properties;
	NSString* defaultImage = [playerProperties stringForKey:@"defaultImage"];
	if (defaultImage.length > 0)
	{
		_playerSprite = [SKSpriteNode spriteNodeWithImageNamed:defaultImage];
		playerSize = _playerSprite.size;
	}
	else
	{
		_playerSprite = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:playerSize];
	}
	[self addChild:_playerSprite];
	
	CGSize bboxSize = playerSize;
	bboxSize.width -= 8;
	bboxSize.height -= 8;
	[self physicsBodyWithRectangleOfSize:bboxSize];
	self.physicsBody.contactTestBitMask = 0xFFFFFFFF;
	self.physicsBody.affectedByGravity = NO;
	self.name = @"player";
	self.position = playerPosition;
	
	self.physicsBody.allowsRotation = [playerProperties numberForKey:@"allowsRotation"].boolValue;
	self.physicsBody.angularDamping = [playerProperties numberForKey:@"angularDamping"].floatValue;
	self.physicsBody.linearDamping = [playerProperties numberForKey:@"linearDamping"].floatValue;
	self.physicsBody.friction = [playerProperties numberForKey:@"friction"].floatValue;
	self.physicsBody.mass = [playerProperties numberForKey:@"mass"].floatValue;
	self.physicsBody.restitution = [playerProperties numberForKey:@"restitution"].floatValue;
	LOG_EXPR(self.physicsBody.allowsRotation);
	LOG_EXPR(self.physicsBody.angularDamping);
	LOG_EXPR(self.physicsBody.linearDamping);
	LOG_EXPR(self.physicsBody.friction);
	LOG_EXPR(self.physicsBody.mass);
	LOG_EXPR(self.physicsBody.density);
	LOG_EXPR(self.physicsBody.restitution);
	LOG_EXPR(self.physicsBody.area);
	
	// apply Tiled properties to ivars
	KKIvarSetter* ivarSetter = [[KKIvarSetter alloc] initWithClass:[self class]];
	[ivarSetter setIvarsFromDictionary:playerProperties.properties target:self];
	LOG_EXPR(_jumpSpeedInitial);
	LOG_EXPR(_jumpSpeedDeceleration);
	LOG_EXPR(_fallSpeedAcceleration);
	LOG_EXPR(_fallSpeedLimit);
	LOG_EXPR(_runSpeedAcceleration);
	
	// limit maximum speed of the player
	if ([playerProperties numberForKey:@"velocityLimit"])
	{
		CGFloat limit = [playerProperties numberForKey:@"velocityLimit"].doubleValue;
		[self addBehavior:[KKLimitVelocityBehavior limitVelocity:limit]];
	}
	
	// prevent player from leaving the area
	if ([playerProperties numberForKey:@"stayInBounds"].boolValue)
	{
		[self addBehavior:[KKStayInBoundsBehavior stayInBounds:movementBounds]];
	}
	
	// make the camera follow the player
	[self addBehavior:[KKCameraFollowBehavior behavior] withKey:@"camera"];


	// observe joypad
	[self observeNotification:KKControlPadDidChangeDirectionNotification
					 selector:@selector(controlPadDidChangeDirection:)];
	[self observeNotification:KKButtonDidExecuteNotification
					 selector:@selector(jumpButtonPressed:)];
	[self observeNotification:KKButtonDidExecuteNotification
					 selector:@selector(attackButtonPressed:)];
	
	// receive updates
	[self observeSceneEvents];
}

-(void) controlPadDidChangeDirection:(NSNotification*)note
{
	KKControlPadBehavior* controlPad = [note.userInfo objectForKey:@"behavior"];
	if (controlPad.direction == KKArcadeJoystickNone)
	{
		_running = NO;
		_currentControlPadDirection = CGPointZero;
	}
	else
	{
		_running = YES;
		_currentControlPadDirection = ccpMult(vectorFromJoystickState(controlPad.direction), _runSpeedAcceleration);
	}
}

-(void) attackButtonPressed:(NSNotification*)note
{
	NSLog(@"attack!");
}

-(void) jumpButtonPressed:(NSNotification*)note
{
	CGPoint velocity = self.physicsBody.velocity;
	if (velocity.y <= 0)
	{
		_jumping = YES;
		velocity.y = 0;
		self.physicsBody.velocity = velocity;
		[self.physicsBody applyImpulse:CGPointMake(0, _jumpSpeedInitial)];
	}
}

-(void) update:(NSTimeInterval)currentTime
{
	CGPoint velocity = self.physicsBody.velocity;
	if (velocity.y > 0.0)
	{
		if (_jumping)
		{
			velocity.y -= _jumpSpeedDeceleration;
			if (velocity.y <= 0.0)
			{
				_jumping = NO;
			}
		}
		else
		{
			// prevent physics body bouncing upon hitting ground
			velocity.y = 0.0;
		}
	}
	else
	{
		velocity.y -= _fallSpeedAcceleration;
	}
	velocity.y = MAX(velocity.y, -_fallSpeedLimit);

	if (_running)
	{
		velocity.x += _currentControlPadDirection.x;
		velocity.x = MIN(velocity.x, _runSpeedLimit);
		velocity.x = MAX(velocity.x, -_runSpeedLimit);
	}
	else if (velocity.x != 0.0)
	{
		if (velocity.x > 0.0)
		{
			velocity.x -= _runSpeedDeceleration;
			if (velocity.x < 0.0)
			{
				velocity.x = 0.0;
			}
		}
		else
		{
			velocity.x += _runSpeedDeceleration;
			if (velocity.x > 0.0)
			{
				velocity.x = 0.0;
			}
		}
	}
	
	self.physicsBody.velocity = velocity;
	
	//NSLog(@"pos: {%.0f, %.0f}", _playerCharacter.position.x, _playerCharacter.position.y);
	//NSLog(@"pos: {%.0f, %.0f}", _tilemapNode.mainTileLayerNode.position.x, _tilemapNode.mainTileLayerNode.position.y);
}

@end
