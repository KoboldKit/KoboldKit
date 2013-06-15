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

NSString* const KKButtonDidExecute = @"KKButtonBehavior:execute";
static NSString* const ScaleActionKey = @"KKButtonBehavior:ScaleAction";

@implementation KKButtonBehavior

-(void) dealloc
{
	NSLog(@"dealloc: %@", self);
}

-(void) didJoinController
{
	_selectedScale = 1.1f;
	[self.node.kkScene addInputEventsObserver:self];
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
		KKNode* node = self.node;
		_originalXScale = node.xScale;
		_originalYScale = node.yScale;
		[node runAction:[SKAction scaleXBy:_selectedScale y:_selectedScale duration:0.05f] withKey:ScaleActionKey];
	}
}

-(void) endSelect
{
	_isSelected = NO;
	
	if (_selectedScale < 1.0 || _selectedScale > 1.0)
	{
		KKNode* node = self.node;
		[node runAction:[SKAction scaleXTo:_originalXScale y:_originalYScale duration:0.05f] withKey:ScaleActionKey];
	}
}

-(void) execute
{
	[[NSNotificationCenter defaultCenter] postNotificationName:KKButtonDidExecute object:self.node userInfo:@{@"behavior" : self}];
}

#if TARGET_OS_IPHONE
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch* touch in touches)
	{
		if ([self.node containsPoint:[touch locationInNode:self.node.scene]])
		{
			[self beginSelect];
		}
	}
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	BOOL lostFocus = YES;
	for (UITouch* touch in touches)
	{
		if ([self.node containsPoint:[touch locationInNode:self.node.scene]])
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

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_isSelected)
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
static NSString* const ArchiveKeyForOriginalXScale = @"_originalXScale";
static NSString* const ArchiveKeyForOriginalYScale = @"_originalYScale";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	if (self)
	{
		_originalXScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalXScale];
		_originalYScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalYScale];
		_selectedScale = [decoder decodeDoubleForKey:ArchiveKeyForFocusScale];
		_isSelected = [decoder decodeBoolForKey:ArchiveKeyForHasFocus];
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
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKButtonBehavior* copy = [[[self class] allocWithZone:zone] init];
	copy->_originalXScale = _originalXScale;
	copy->_originalYScale = _originalYScale;
	copy->_selectedScale = _selectedScale;
	copy->_isSelected = _isSelected;
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
			_selectedScale == behavior.selectedScale &&
			_isSelected == behavior.isSelected);
}

@end
