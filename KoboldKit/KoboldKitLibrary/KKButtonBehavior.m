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

-(void) didJoinController
{
	_selectedScale = 1.1f;
	[self.node.kkScene registerInputReceiver:self];
}

-(void) didLeaveController
{
	[self.node.kkScene unregisterInputReceiver:self];
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
		LOG_EXPR([touch locationInNode:self.node]);
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
		_selectedScale = [decoder decodeDoubleForKey:ArchiveKeyForFocusScale];
		_originalXScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalXScale];
		_originalYScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalYScale];
		_isSelected = [decoder decodeBoolForKey:ArchiveKeyForHasFocus];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeDouble:_selectedScale forKey:ArchiveKeyForFocusScale];
	[encoder encodeDouble:_originalXScale forKey:ArchiveKeyForOriginalXScale];
	[encoder encodeDouble:_originalYScale forKey:ArchiveKeyForOriginalYScale];
	[encoder encodeBool:_isSelected forKey:ArchiveKeyForHasFocus];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKNodeBehavior* copy = [[[self class] allocWithZone:zone] init];
	//copy->_node = _node;
	return copy;
}
@end
