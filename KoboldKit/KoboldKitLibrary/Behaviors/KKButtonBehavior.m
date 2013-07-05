//
//  KKButtonBehavior.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKButtonBehavior.h"
#import "KKMacros.h"
#import "KKScene.h"
#import "SKNode+KoboldKit.h"

NSString* const KKButtonDidExecuteNotification = @"KKButtonBehavior:execute";
static NSString* const ScaleActionKey = @"KKButtonBehavior:ScaleAction";

@implementation KKButtonBehavior

-(void) dealloc
{
	NSLog(@"dealloc: %@", self);
}

-(void) didJoinController
{
	_selectedScale = 1.1f;

	SKNode* node = self.node;
	[node.kkScene addInputEventsObserver:self];
	_originalXScale = node.xScale;
	_originalYScale = node.yScale;

	if (_selectedTexture)
	{
		SKSpriteNode* sprite = (SKSpriteNode*)self.node;
		if ([sprite isKindOfClass:[SKSpriteNode class]])
		{
			_originalTexture = sprite.texture;
		}
	}
}

-(void) didLeaveController
{
	[self.node.kkScene removeInputEventsObserver:self];
}

-(void) beginSelect
{
	_isSelected = YES;

	if (_selectedScale < 1.0 || _selectedScale > 1.0)
	{
		SKNode* node = self.node;
		node.xScale = _originalXScale;
		node.yScale = _originalYScale;
		[node runAction:[SKAction scaleXBy:_selectedScale y:_selectedScale duration:0.05f] withKey:ScaleActionKey];
	}
	
	if (_selectedTexture)
	{
		SKSpriteNode* sprite = (SKSpriteNode*)self.node;
		sprite.texture = _selectedTexture;
	}
	
	if (_executesWhenPressed)
	{
		[self execute];
		[self performSelector:@selector(endSelect) withObject:nil afterDelay:0.01];
	}
}

-(void) endSelect
{
	_isSelected = NO;
	
	if (_selectedScale < 1.0 || _selectedScale > 1.0)
	{
		SKNode* node = self.node;
		[node runAction:[SKAction scaleXTo:_originalXScale y:_originalYScale duration:0.05f] withKey:ScaleActionKey];
	}

	if (_originalTexture)
	{
		SKSpriteNode* sprite = (SKSpriteNode*)self.node;
		sprite.texture = _originalTexture;
	}
}

-(void) execute
{
	[self postNotificationName:KKButtonDidExecuteNotification];
}

-(void) setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	if (enabled == NO)
	{
		[self endSelect];
	}
}

#if TARGET_OS_IPHONE
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.enabled)
	{
		for (UITouch* touch in touches)
		{
			if ([self.node containsPoint:[touch locationInNode:self.node.parent]])
			{
				[self beginSelect];
			}
		}
	}
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.enabled)
	{
		BOOL lostFocus = YES;
		for (UITouch* touch in touches)
		{
			if ([self.node containsPoint:[touch locationInNode:self.node.parent]])
			{
				lostFocus = NO;
				break;
			}
		}
		
		if (lostFocus && _isSelected)
		{
			[self endSelect];
		}
		if (lostFocus == NO && _isSelected == NO)
		{
			[self beginSelect];
		}
	}
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_isSelected && self.enabled)
	{
		[self endSelect];
		[self execute];
	}
}
#elif TARGET_OS_MAC
#endif

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

static NSString* const ArchiveKeyForExecuteBlock = @"executeBlock";
static NSString* const ArchiveKeyForFocusScale = @"focusScale";
static NSString* const ArchiveKeyForHasFocus = @"hasFocus";
static NSString* const ArchiveKeyForOriginalXScale = @"originalXScale";
static NSString* const ArchiveKeyForOriginalYScale = @"originalYScale";
static NSString* const ArchiveKeyForOriginalTexture = @"originalTexture";
static NSString* const ArchiveKeyForSelectedTexture = @"selectedTexture";
static NSString* const ArchiveKeyForExecutesWhenPressed = @"executesWhenPressed";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	if (self)
	{
		_originalXScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalXScale];
		_originalYScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalYScale];
		_selectedScale = [decoder decodeDoubleForKey:ArchiveKeyForFocusScale];
		_isSelected = [decoder decodeBoolForKey:ArchiveKeyForHasFocus];
		_originalTexture = [decoder decodeObjectForKey:ArchiveKeyForOriginalTexture];
		_selectedTexture = [decoder decodeObjectForKey:ArchiveKeyForSelectedTexture];
		_executesWhenPressed = [decoder decodeBoolForKey:ArchiveKeyForExecutesWhenPressed];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeDouble:_originalXScale forKey:ArchiveKeyForOriginalXScale];
	[encoder encodeDouble:_originalYScale forKey:ArchiveKeyForOriginalYScale];
	[encoder encodeDouble:_selectedScale forKey:ArchiveKeyForFocusScale];
	[encoder encodeBool:_isSelected forKey:ArchiveKeyForHasFocus];
	[encoder encodeObject:_originalTexture forKey:ArchiveKeyForOriginalTexture];
	[encoder encodeObject:_selectedTexture forKey:ArchiveKeyForSelectedTexture];
	[encoder encodeBool:_executesWhenPressed forKey:ArchiveKeyForExecutesWhenPressed];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKButtonBehavior* copy = [[super copyWithZone:zone] init];
	copy->_originalXScale = _originalXScale;
	copy->_originalYScale = _originalYScale;
	copy->_selectedScale = _selectedScale;
	copy->_isSelected = _isSelected;
	copy->_originalTexture = _originalTexture;
	copy->_selectedTexture = _selectedTexture;
	copy->_executesWhenPressed = _executesWhenPressed;
	return copy;
}

#pragma mark Equality

-(BOOL) isEqualToBehavior:(KKButtonBehavior*)behavior
{
	if ([super isEqualToBehavior:behavior] == NO)
		return NO;
	
	// custom equality checks
	return (_originalXScale == behavior->_originalXScale &&
			_originalYScale == behavior->_originalYScale &&
			_selectedScale == behavior->_selectedScale &&
			_isSelected == behavior->_isSelected &&
			_originalTexture == behavior->_originalTexture &&
			_selectedTexture == behavior->_selectedTexture &&
			_executesWhenPressed == behavior->_executesWhenPressed);
}

@end
