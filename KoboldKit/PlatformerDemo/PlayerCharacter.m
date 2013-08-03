//
//  PlayerCharacter.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 10.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "PlayerCharacter.h"

@implementation PlayerCharacter

-(SKPhysicsBody*) physicsBodyWithTilemapObject:(KKTilemapObject *)tilemapObject
{
	return [self physicsBodyWithRectangleOfSize:_boundingBox];
}

-(void) nodeDidSpawnWithTilemapObject:(KKTilemapObject*)tilemapObject
{
	[self setupPlayerSpriteWithObject:tilemapObject];
	
	// 1st parent = object layer node, 2nd parent = tile layer node, 3rd parent = tilemap node
	KKTilemapNode* tilemapNode = (KKTilemapNode*)self.parent.parent.parent;
	NSAssert1([tilemapNode isKindOfClass:[KKTilemapNode class]], @"player.parent.parent.parent (%@) is not a KKTilemapNode!", tilemapNode);

	// update bounds behavior with tilemap bounds
	KKStayInBoundsBehavior* stayInBoundsBehavior = [self behaviorKindOfClass:[KKStayInBoundsBehavior class]];
	stayInBoundsBehavior.bounds = tilemapNode.bounds;

	// receive updates
	[self observeSceneEvents];
}

-(void) setupPlayerSpriteWithObject:(KKTilemapObject*)playerObject
{
	CGSize playerSize = playerObject.size;
	
	if (_defaultImage.length)
	{
		SKTexture* texture = [SKTexture textureWithImageNamed:_defaultImage];
		if (texture)
		{
			_playerSprite = [KKSpriteNode spriteNodeWithImageNamed:_defaultImage];
		}
		else
		{
			SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:@"Jetpack"];
			texture = [atlas textureNamed:_defaultImage];
			_playerSprite = [KKSpriteNode spriteNodeWithTexture:texture];
		}

		playerSize = _playerSprite.size;
	}
	else
	{
		_playerSprite = [KKSpriteNode spriteNodeWithColor:[SKColor redColor] size:playerSize];
	}
	
	[self addChild:_playerSprite];
}

-(void) die
{
	[self disregardSceneEvents];
	self.physicsBody = nil;
	
	KKEmitterNode* emitter = [KKEmitterNode emitterWithFile:@"playerdeath.sks"];
	emitter.position = CGPointMake(self.position.x, self.position.y - _playerSprite.size.height / 2.0);
	[self.parent addChild:emitter];

	[emitter advanceSimulationTime:0.08];
	NSArray* sequence = @[[SKAction waitForDuration:0.1], [SKAction runBlock:^{emitter.particleBirthRate = 0.0;}], [SKAction waitForDuration:7.0], [SKAction removeFromParent]];
	[emitter runAction:[SKAction sequence:sequence]];
	
	sequence = @[[SKAction fadeOutWithDuration:0.2], [SKAction removeFromParent]];
	[_playerSprite runAction:[SKAction sequence:sequence]];
	[self runAction:[SKAction sequence:sequence]];
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
		CGFloat speed = _runSpeedAcceleration;
		if (speed == 0.0 || speed > _runSpeedLimit)
		{
			speed = _runSpeedLimit;
		}
		_currentControlPadDirection = ccpMult(vectorFromJoystickState(controlPad.direction), speed);
	}
}

-(void) attackButtonPressed:(NSNotification*)note
{
	NSLog(@"attack!");
}

-(void) jumpButtonPressed:(NSNotification*)note
{
	CGPoint velocity = self.physicsBody.velocity;
	if (_jumping == NO /*&& velocity.y > -0.001 && velocity.y < 0.001*/)
	{
		_jumping = YES;
		velocity.y = _jumpSpeedInitial;
		self.physicsBody.velocity = velocity;
		
		_jumpButton = [note.userInfo objectForKey:@"behavior"];
	}
}

-(void) jumpButtonReleased:(NSNotification *)note
{
	if (_jumping)
	{
		[self endJump];

		CGPoint velocity = self.physicsBody.velocity;
		if (velocity.y > _jumpAbortVelocity)
		{
			velocity.y = _jumpAbortVelocity;
		}
		self.physicsBody.velocity = velocity;
	}
}

-(void) endJump
{
	_jumping = NO;
	
	[_jumpButton endSelect];
	_jumpButton = nil;
}

-(void) update:(NSTimeInterval)currentTime
{
	CGPoint velocity = self.physicsBody.velocity;
	if (_jumping)
	{
		if (velocity.y > 0.0)
		{
			velocity.y -= _jumpSpeedDeceleration;
		}
		else
		{
			[self endJump];
		}
	}
	else
	{
		if (_fallSpeedAcceleration == 0.0 || _fallSpeedAcceleration >= _fallSpeedLimit)
		{
			velocity.y = -_fallSpeedLimit;
		}
		else
		{
			velocity.y -= _fallSpeedAcceleration;
		}
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
		if (_runSpeedDeceleration == 0)
		{
			velocity.x = 0.0;
		}
		else if (velocity.x > 0.0)
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
	
	/*
	NSLog(@"----------------------------");
	LOG_EXPR(_playerSprite.position);
	LOG_EXPR(_playerSprite.parent.position);
	LOG_EXPR(_playerSprite.parent.parent.position);
	LOG_EXPR(_playerSprite.parent.parent.parent.position);
	 */
}

/*
-(void) didBeginContact:(SKPhysicsContact*)contact
{
	SKPhysicsBody* myBody = self.physicsBody;
	if (contact.bodyA == myBody || contact.bodyB == myBody)
	{
		// FIXME: this should actually check for collision with floor
		
		// prevent jitter on floor
		CGPoint velocity = myBody.velocity;
		velocity.y = 0.0;
		myBody.velocity = velocity;
	}
}

-(void) didEndContact:(SKPhysicsContact*)contact
{
	SKPhysicsBody* myBody = self.physicsBody;
	if (contact.bodyA == myBody || contact.bodyB == myBody)
	{
		_inContact = NO;
	}
}
*/

@end
