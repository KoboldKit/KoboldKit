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

+(id) buttonWithBlock:(KKButtonExecuteBlock)executeBlock
{
	return [[self alloc] initWithBlock:executeBlock];
}

-(id) initWithBlock:(KKButtonExecuteBlock)executeBlock
{
	self = [super init];
	if (self)
	{
	}
	return self;
}

-(void) didJoinController
{
	_focusScale = 1.1f;
	[self.node.kkScene registerInputReceiver:self];
}

-(void) didLeaveController
{
	[self.node.kkScene unregisterInputReceiver:self];
}

-(void) gainFocus
{
	_hasFocus = YES;
	
	KKNode* node = self.node;
	_originalXScale = node.xScale;
	_originalYScale = node.yScale;
	[node runAction:[SKAction scaleXBy:_focusScale y:_focusScale duration:0.05f] withKey:ScaleActionKey];
	NSLog(@"gain");
}

-(void) loseFocus
{
	_hasFocus = NO;
	
	KKNode* node = self.node;
	[node runAction:[SKAction scaleXTo:_originalXScale y:_originalYScale duration:0.05f] withKey:ScaleActionKey];
	NSLog(@"lost");
}

-(void) execute
{
	NSLog(@"execute");
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
			[self gainFocus];
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
	
	if (lostFocus && _hasFocus)
	{
		[self loseFocus];
	}
	if (lostFocus == NO && _hasFocus == NO)
	{
		[self gainFocus];
	}
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_hasFocus)
	{
		[self loseFocus];
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
		_focusScale = [decoder decodeDoubleForKey:ArchiveKeyForFocusScale];
		_originalXScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalXScale];
		_originalYScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalYScale];
		_hasFocus = [decoder decodeBoolForKey:ArchiveKeyForHasFocus];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeDouble:_focusScale forKey:ArchiveKeyForFocusScale];
	[encoder encodeDouble:_originalXScale forKey:ArchiveKeyForOriginalXScale];
	[encoder encodeDouble:_originalYScale forKey:ArchiveKeyForOriginalYScale];
	[encoder encodeBool:_hasFocus forKey:ArchiveKeyForHasFocus];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKBehavior* copy = [[[self class] allocWithZone:zone] init];
	//copy->_node = _node;
	return copy;
}
@end
