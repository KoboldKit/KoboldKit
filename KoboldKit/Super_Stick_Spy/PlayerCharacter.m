//
//  PlayerCharacter.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 10.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "PlayerCharacter.h"

@implementation PlayerCharacter

-(id) init
{
	self = [super init];
	if (self)
	{
		// default anchorPoint
		self.anchorPoint = CGPointMake(0.5, 0.5);
	}
	return self;
}

-(SKPhysicsBody*) physicsBodyWithTilemapObject:(KKTilemapObject *)tilemapObject
{
	return [self physicsBodyWithRectangleOfSize:_boundingBox];
}

// called from spawning objects via Tilemap node
-(void) nodeDidSpawnWithTilemapObject:(KKTilemapObject*)tilemapObject
{
	_tilemapPlayerObject = tilemapObject;
	_respawnPosition = self.position;

	NSAssert(_defaultImage.length, @"defaultImage property not set for player object in Tiled!");
	_playerSprite = [KKSpriteNode spriteNodeWithImageNamed:_defaultImage];
	_playerSprite.anchorPoint = _anchorPoint;
	[self addChild:_playerSprite];

	// 1st parent = object layer node, 2nd parent = tile layer node, 3rd parent = tilemap node
	KKTilemapNode* tilemapNode = (KKTilemapNode*)self.parent.parent.parent;
	NSAssert1([tilemapNode isKindOfClass:[KKTilemapNode class]], @"player.parent.parent.parent (%@) is not a KKTilemapNode!", tilemapNode);

	// update bounds behavior with tilemap bounds
	KKStayInBoundsBehavior* stayInBoundsBehavior = [self behaviorKindOfClass:[KKStayInBoundsBehavior class]];
	stayInBoundsBehavior.bounds = tilemapNode.bounds;

	// receive updates
	[self observeSceneEvents];
}

-(void) die
{
	// death hides the player, plays an effect, then "respawns" player after some time
	[self playSoundFileNamed:@"die.wav"];
	
	[self disregardSceneEvents];
	self.physicsBody.velocity = CGPointZero;
	_currentControlPadDirection = CGPointZero;
	
	KKEmitterNode* emitter = [KKEmitterNode emitterWithFile:@"playerdeath.sks"];
	emitter.position = CGPointMake(self.position.x, self.position.y - _playerSprite.size.height / 2.0);
	[self.parent addChild:emitter];

	[emitter advanceSimulationTime:0.15];
	NSArray* sequence = @[[SKAction waitForDuration:0.1], [SKAction runBlock:^{ emitter.particleBirthRate = 0.0; }], [SKAction waitForDuration:7.0], [SKAction removeFromParent]];
	[emitter runAction:[SKAction sequence:sequence]];
	
	SKAction* fadeOutAction = [SKAction fadeOutWithDuration:0.2];
	[_playerSprite runAction:fadeOutAction];
	[self runAction:fadeOutAction];
	
	sequence = @[[SKAction waitForDuration:1.5], [SKAction runBlock:^{ [self respawn]; }]];
	[self runAction:[SKAction sequence:sequence]];
}

-(void) respawn
{
	[self playSoundFileNamed:@"respawn.wav"];

	_playerSprite.alpha = 1.0;
	self.alpha = 1.0;
	[self observeSceneEvents];
	[self moveToCheckpoint];
}

-(void) setCheckpoint:(KKTilemapObject*)checkpointObject
{
	// center respawn position on checkpoint object
	CGPoint respawnPos = CGPointMake(checkpointObject.position.x + checkpointObject.size.width / 2.0,
									 checkpointObject.position.y + checkpointObject.size.height / 2.0);
	
	if (CGPointEqualToPoint(respawnPos, _respawnPosition) == NO)
	{
		_respawnPosition = respawnPos;
		[self playSoundFileNamed:@"checkpoint.wav"];
	}
}

-(void) moveToCheckpoint
{
	self.position = _respawnPosition;
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

-(void) jumpButtonPressed:(NSNotification*)note
{
	CGPoint velocity = self.physicsBody.velocity;
	if (_onFloor && _jumping == NO)
	{
		_onFloor = NO;
		_jumping = YES;
		velocity.y = _jumpSpeedInitial;
		self.physicsBody.velocity = velocity;
		
		_jumpButton = [note.userInfo objectForKey:@"behavior"];
		
		[self playSoundFileNamed:@"jump.wav"];
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
	// custom non-physics velocity to tweak player's behavior to be less like a physics body but a "real" jump'n run character
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
	else if (_onFloor == NO)
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
	else
	{
		velocity.y = 0.0;
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
}

-(void) testPlayerOnFloor
{
	_onFloor = NO;
	CGPoint rayStart = self.position;
	CGPoint rayEnd = CGPointMake(rayStart.x, rayStart.y - (_playerSprite.size.height / 2.0 + 2));
	
	// find body below player
	SKPhysicsWorld* physicsWorld = self.scene.physicsWorld;
	[physicsWorld enumerateBodiesAlongRayStart:rayStart end:rayEnd usingBlock:^(SKPhysicsBody *body, CGPoint point, CGPoint normal, BOOL *stop) {
		if (body.contactTestBitMask <= 1)
		{
			_onFloor = YES;
			
			// force the player at the same y coord on the floor (they physics engine will force the player back up to the edge)
			point.y += _playerSprite.size.height / 2.0;
			self.position = point;
			
			*stop = YES;
		}
	}];
}

-(void) didEvaluateActions
{
	[self testPlayerOnFloor];
}

@end
