/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * Super_Stick_Spy/SuperStickSpy.License.txt
 */


#import "PlayerCharacter.h"
#import "KKEntity.h"

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
	_entity = self.entity;

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
	[[OALSimpleAudio sharedInstance] playEffect:@"die.wav"];

	[self disregardSceneEvents];
	self.physicsBody.velocity = CGVectorZero;
	_currentControlPadDirection = CGVectorZero;
	
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
	[[OALSimpleAudio sharedInstance] playEffect:@"respawn.wav"];

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
		[[OALSimpleAudio sharedInstance] playEffect:@"checkpoint.wav"];
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
		_currentControlPadDirection = CGVectorZero;
	}
	else
	{
		_running = YES;
		CGFloat speed = _runSpeedAcceleration;
		if (speed == 0.0 || speed > _runSpeedLimit)
		{
			speed = _runSpeedLimit;
		}
		_currentControlPadDirection = ccvMult(vectorFromJoystickState(controlPad.direction), speed);
	}
}

-(void) jumpButtonPressed:(NSNotification*)note
{
	CGPoint velocity = _entity.velocity;
	if (/*_onFloor &&*/ _jumping == NO)
	{
		_onFloor = NO;
		_jumping = YES;
		velocity.y = _jumpSpeedInitial;
		_entity.velocity = velocity;
		
		_jumpButton = [note.userInfo objectForKey:@"behavior"];
		
		[[OALSimpleAudio sharedInstance] playEffect:@"jump.wav"];
	}
}

-(void) jumpButtonReleased:(NSNotification *)note
{
	if (_jumping)
	{
		[self endJump];

		CGPoint velocity = _entity.velocity;
		if (velocity.y > _jumpAbortVelocity)
		{
			velocity.y = _jumpAbortVelocity;
		}
		_entity.velocity = velocity;
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
	CGPoint velocity = _entity.velocity;
	velocity.x = _currentControlPadDirection.dx;
	_entity.velocity = velocity;
}

/*
-(void) update:(NSTimeInterval)currentTime
{
	// custom non-physics velocity to tweak player's behavior to be less like a physics body but a "real" jump'n run character
	CGVector velocity = self.physicsBody.velocity;
	if (_jumping)
	{
		if (velocity.dy > 0.0)
		{
			velocity.dy -= _jumpSpeedDeceleration;
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
			velocity.dy = -_fallSpeedLimit;
		}
		else
		{
			velocity.dy -= _fallSpeedAcceleration;
		}
	}
	else
	{
		velocity.dy = 0.0;
	}
	
	velocity.dy = MAX(velocity.dy, -_fallSpeedLimit);

	if (_running)
	{
		velocity.dx += _currentControlPadDirection.dx;
		velocity.dx = MIN(velocity.dx, _runSpeedLimit);
		velocity.dx = MAX(velocity.dx, -_runSpeedLimit);
	}
	else if (velocity.dx != 0.0)
	{
		if (_runSpeedDeceleration == 0)
		{
			velocity.dx = 0.0;
		}
		else if (velocity.dx > 0.0)
		{
			velocity.dx -= _runSpeedDeceleration;
			if (velocity.dx < 0.0)
			{
				velocity.dx = 0.0;
			}
		}
		else
		{
			velocity.dx += _runSpeedDeceleration;
			if (velocity.dx > 0.0)
			{
				velocity.dx = 0.0;
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
	[physicsWorld enumerateBodiesAlongRayStart:rayStart end:rayEnd usingBlock:^(SKPhysicsBody *body, CGPoint point, CGVector normal, BOOL *stop) {
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
*/

@end
