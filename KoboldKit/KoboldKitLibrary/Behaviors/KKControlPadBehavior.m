//
//  KKControlPadBehavior.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 21.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKControlPadBehavior.h"
#import "SKNode+KoboldKit.h"
#import "KKScene.h"
#import "CGPointExtension.h"

NSString* const KKControlPadDidChangeDirectionNotification = @"KKControlPadDidChangeDirection:notification";

@implementation KKControlPadBehavior

+(id) controlPadBehaviorWithTextures:(NSArray*)textures
{
	return [[self alloc] initWithTextures:textures];
}

-(id) initWithTextures:(NSArray*)textures
{
	self = [super init];
	if (self)
	{
		NSAssert1(textures.count == 2 || textures.count == 4 || textures.count == 8, @"KKControlPadBehavior requires either 2, 4 or 8 textures (2, 4 or 8 directions). Got these textures: %@", textures);
		_textures = textures;
		_directionsCount = _textures.count;
		_deadZone = 10.0;
	}
	return self;
}

-(void) didJoinController
{
	NSAssert1([self.node isKindOfClass:[SKSpriteNode class]], @"KKControlPadBehavior can only be used with SKSpriteNode nodes, tried to use it on: %@", self.node);
	
	KKSpriteNode* sprite = (KKSpriteNode*)self.node;
	NSMutableArray* textures = [NSMutableArray arrayWithObject:sprite.texture];
	[textures addObjectsFromArray:_textures];
	_textures = textures;
	
	[self.node.kkScene addInputEventsObserver:self];
}

-(void) didLeaveController
{
	[self.node.kkScene removeInputEventsObserver:self];
}

#pragma mark input event handling

-(void) updateDirectionFromLocation:(CGPoint)location
{
	KKArcadeInputState newDirection = KKArcadeJoystickNone;
	KKSpriteNode* sprite = (KKSpriteNode*)self.node;
	CGPoint locationInNodeSpace = [sprite convertPoint:location fromNode:sprite.parent];

	if (_directionsCount == 2)
	{
		CGSize size = sprite.size;
		CGSize halfSize = CGSizeMake(size.width / 2, size.height / 2);
		if (_vertical)
		{
			CGRect up = CGRectMake(-halfSize.width, _deadZone, size.width, halfSize.height - _deadZone);
			CGRect down = CGRectMake(-halfSize.width, -halfSize.height, size.width, halfSize.height - _deadZone);
			if (CGRectContainsPoint(up, locationInNodeSpace))
			{
				newDirection = KKArcadeJoystickUp;
			}
			else if (CGRectContainsPoint(down, locationInNodeSpace))
			{
				newDirection = KKArcadeJoystickDown;
			}
		}
		else
		{
			CGRect right = CGRectMake(_deadZone, -halfSize.height, halfSize.width - _deadZone, size.height);
			CGRect left = CGRectMake(-halfSize.width, -halfSize.height, halfSize.width - _deadZone, size.height);
			if (CGRectContainsPoint(right, locationInNodeSpace))
			{
				newDirection = KKArcadeJoystickRight;
			}
			else if (CGRectContainsPoint(left, locationInNodeSpace))
			{
				newDirection = KKArcadeJoystickLeft;
			}
		}
	}
	else
	{
		// check against deadzone
		CGFloat distanceFromCenterSquared = ccpDot(locationInNodeSpace, locationInNodeSpace);
		if (distanceFromCenterSquared > (_deadZone * _deadZone))
		{
			// calculate the positive angle from center
			CGFloat angle = atan2f(locationInNodeSpace.y, locationInNodeSpace.x);
			if (angle < 0)
			{
				const CGFloat M_PI_2x = M_PI * 2.0;
				angle += M_PI_2x;
			}
			
			// get the direction index (0-8) by subdividing the angles into 4 or 8 chunks
			const CGFloat fourDirRadians = M_PI / 2.0;
			const CGFloat eightDirRadians = M_PI / 4.0;
			CGFloat dpadUnitAngle = (_directionsCount == 8) ? eightDirRadians : fourDirRadians;
			
			NSUInteger directionIndex = roundf(angle / dpadUnitAngle) * (_directionsCount == 8 ? 1.0f : 2.0f);
			switch (directionIndex)
			{
				case 0:
				case 8:
					newDirection = KKArcadeJoystickRight;
					break;
				case 1:
					newDirection = KKArcadeJoystickUpRight;
					break;
				case 2:
					newDirection = KKArcadeJoystickUp;
					break;
				case 3:
					newDirection = KKArcadeJoystickUpLeft;
					break;
				case 4:
					newDirection = KKArcadeJoystickLeft;
					break;
				case 5:
					newDirection = KKArcadeJoystickDownLeft;
					break;
				case 6:
					newDirection = KKArcadeJoystickDown;
					break;
				case 7:
					newDirection = KKArcadeJoystickDownRight;
					break;
			}
		}
	}
	
	if (newDirection != _direction)
	{
		_direction = newDirection;
		[self updateDirectionTexture];
		[self postNotificationName:KKControlPadDidChangeDirectionNotification];
	}
}

-(void) resetDirection
{
	if (_direction != KKArcadeJoystickNone)
	{
		_direction = KKArcadeJoystickNone;
		[self updateDirectionTexture];
		[self postNotificationName:KKControlPadDidChangeDirectionNotification];
	}
}

-(void) updateDirectionTexture
{
	SKTexture* newTexture;
	
	if (_directionsCount == 8)
	{
		switch (_direction)
		{
			case KKArcadeJoystickRight:
				newTexture = [_textures objectAtIndex:1];
				break;
			case KKArcadeJoystickUpRight:
				newTexture = [_textures objectAtIndex:2];
				break;
			case KKArcadeJoystickUp:
				newTexture = [_textures objectAtIndex:3];
				break;
			case KKArcadeJoystickUpLeft:
				newTexture = [_textures objectAtIndex:4];
				break;
			case KKArcadeJoystickLeft:
				newTexture = [_textures objectAtIndex:5];
				break;
			case KKArcadeJoystickDownLeft:
				newTexture = [_textures objectAtIndex:6];
				break;
			case KKArcadeJoystickDown:
				newTexture = [_textures objectAtIndex:7];
				break;
			case KKArcadeJoystickDownRight:
				newTexture = [_textures objectAtIndex:8];
				break;
				
			default:
				newTexture = [_textures firstObject];
				break;
		}
	}
	else if (_directionsCount == 4)
	{
		switch (_direction)
		{
			case KKArcadeJoystickRight:
				newTexture = [_textures objectAtIndex:1];
				break;
			case KKArcadeJoystickUp:
				newTexture = [_textures objectAtIndex:2];
				break;
			case KKArcadeJoystickLeft:
				newTexture = [_textures objectAtIndex:3];
				break;
			case KKArcadeJoystickDown:
				newTexture = [_textures objectAtIndex:4];
				break;
				
			default:
				newTexture = [_textures firstObject];
				break;
		}
	}
	else
	{
		switch (_direction)
		{
			case KKArcadeJoystickRight:
			case KKArcadeJoystickUp:
				newTexture = [_textures objectAtIndex:1];
				break;
			case KKArcadeJoystickLeft:
			case KKArcadeJoystickDown:
				newTexture = [_textures objectAtIndex:2];
				break;
				
			default:
				newTexture = [_textures firstObject];
				break;
		}
	}

	SKSpriteNode* sprite = (SKSpriteNode*)self.node;
	sprite.texture = newTexture;
}

-(void) inputEnded
{
	[self resetDirection];
}

#pragma mark Input Events

#if TARGET_OS_IPHONE
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.enabled && _trackedTouch == nil)
	{
		for (UITouch* touch in touches)
		{
			SKNode* node = self.node;
			CGPoint touchLocation = [touch locationInNode:node.parent];
			BOOL locationOnDpad = [node containsPoint:touchLocation];
			if (locationOnDpad)
			{
				_trackedTouch = touch;
				[self updateDirectionFromLocation:touchLocation];
				break;
			}
		}
	}
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.enabled)
	{
		for (UITouch* touch in touches)
		{
			if (touch == _trackedTouch)
			{
				[self updateDirectionFromLocation:[touch locationInNode:self.node.parent]];
			}
		}
	}
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.enabled)
	{
		for (UITouch* touch in touches)
		{
			if (touch == _trackedTouch)
			{
				_trackedTouch = nil;
				[self inputEnded];
				break;
			}
		}
	}
}
#elif TARGET_OS_MAC
#endif

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

static NSString* const ArchiveKeyForDeadZone = @"deadZone";
static NSString* const ArchiveKeyForDirection = @"direction";
static NSString* const ArchiveKeyForTextures = @"textures";
static NSString* const ArchiveKeyForAllowDiagonal = @"allowDiagonalDirection";
static NSString* const ArchiveKeyForInUse = @"_originalYScale";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	if (self)
	{
		/*
		_originalXScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalXScale];
		_originalYScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalYScale];
		_selectedScale = [decoder decodeDoubleForKey:ArchiveKeyForFocusScale];
		_isSelected = [decoder decodeBoolForKey:ArchiveKeyForHasFocus];
		 */
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	/*
	[encoder encodeDouble:_originalXScale forKey:ArchiveKeyForOriginalXScale];
	[encoder encodeDouble:_originalYScale forKey:ArchiveKeyForOriginalYScale];
	[encoder encodeDouble:_selectedScale forKey:ArchiveKeyForFocusScale];
	[encoder encodeBool:_isSelected forKey:ArchiveKeyForHasFocus];
	 */
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKControlPadBehavior* copy = [[super copyWithZone:zone] init];
	copy->_textures = [_textures copy];
	copy->_directionsCount = _directionsCount;
	copy->_deadZone = _deadZone;
	copy->_direction = _direction;
	return copy;
}

#pragma mark Equality

-(BOOL) isEqualToBehavior:(KKControlPadBehavior*)behavior
{
	return NO;
	/*
	if ([super isEqualToBehavior:behavior] == NO)
		return NO;
	
	// custom equality checks
	return (_originalXScale == behavior->_originalXScale &&
			_originalYScale == behavior->_originalYScale &&
			_selectedScale == behavior.selectedScale &&
			_isSelected == behavior.isSelected);
	 */
}


@end
