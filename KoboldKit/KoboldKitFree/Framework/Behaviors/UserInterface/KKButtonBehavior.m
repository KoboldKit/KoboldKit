/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKFramework.h"
#import "KKButtonBehavior.h"
#import "KKMacros.h"
#import "KKScene.h"

NSString* const KKButtonDidExecuteNotification = @"KKButtonBehavior:execute";
NSString* const KKButtonDidEndExecuteNotification = @"KKButtonBehavior:endExecute";
static NSString* const ScaleActionKey = @"KKButtonBehavior:ScaleAction";

@implementation KKButtonBehavior

-(id) init
{
	self = [super init];
	if (self)
	{
		_selectedScale = 1.1f;
	}
	return self;
}

-(void) didJoinController
{
	SKNode* node = self.node;
	_originalXScale = node.xScale;
	_originalYScale = node.yScale;

	[node.kkScene addInputEventsObserver:self];

	if (_selectedTexture)
	{
		SKSpriteNode* sprite = (SKSpriteNode*)node;
		if ([sprite isKindOfClass:[SKSpriteNode class]])
		{
			_originalTexture = sprite.texture;
		}
	}
}

-(void) didLeaveController
{
	KKScene* scene = self.node.kkScene;
	[scene removeInputEventsObserver:self];
	[scene removeSceneEventsObserver:self];
	_originalTexture = nil;
}

-(void) didChangeEnabledState
{
	if (self.enabled == NO)
	{
		_trackedTouch = 0;
	}
}

-(void) beginSelect
{
	_selected = YES;

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
	
	if (_executesWhenPressed && _continuous == NO)
	{
		[self execute];
		//[self performSelector:@selector(endSelect) withObject:nil afterDelay:0.01];
	}
}

-(void) endSelect
{
	_selected = NO;
	
	if (_selectedScale < 1.0 || _selectedScale > 1.0)
	{
		SKNode* node = self.node;
		[node runAction:[SKAction scaleXTo:_originalXScale y:_originalYScale duration:0.05f] withKey:ScaleActionKey];
	}

	if (_originalTexture)
	{
		SKSpriteNode* sprite = (SKSpriteNode*)self.node;
		if (sprite.texture != _originalTexture)
		{
			sprite.texture = _originalTexture;
		}
	}
}

-(void) execute
{
	[self postNotificationName:KKButtonDidExecuteNotification];
}

-(void) endExecute
{
	[self endSelect];
	[self postNotificationName:KKButtonDidEndExecuteNotification];
}

-(void) setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	if (enabled == NO)
	{
		[self endSelect];
	}
}

-(void) inputDidMoveLoseFocus:(BOOL)lostFocus
{
	if (lostFocus && _selected)
	{
		(_continuous || _executesWhenPressed) ? [self endExecute] : [self endSelect];
	}
	if (lostFocus == NO && _selected == NO)
	{
		[self beginSelect];
	}
}

-(void) inputDidEnd
{
	if (_selected && self.enabled)
	{
		[self endSelect];
		
		(_continuous || _executesWhenPressed) ? [self endExecute] : [self execute];
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
				if (_trackedTouch)
				{
					NSLog(@"ALERT: button already tracking touch: %x (new touch: %p)", _trackedTouch, touch);
				}
				_trackedTouch = (NSUInteger)touch;
				//NSLog(@"button began: %p", touch);
				[self beginSelect];
				break;
			}
		}
	}
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_trackedTouch)
	{
		BOOL didLoseFocus = NO;
		for (UITouch* touch in touches)
		{
			if ((NSUInteger)touch == _trackedTouch && [self.node containsPoint:[touch locationInNode:self.node.parent]] == NO)
			{
				didLoseFocus = YES;
				[self inputDidMoveLoseFocus:YES];
				break;
			}
		}
		
		if (didLoseFocus == NO)
		{
			[self inputDidMoveLoseFocus:NO];
		}
	}
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"button touches cancelled");
	[self touchesEnded:touches withEvent:event];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_trackedTouch)
	{
		for (UITouch* touch in touches)
		{
			//NSLog(@"button trying end touch: %p", touch);
			if ((NSUInteger)touch == _trackedTouch)
			{
				//NSLog(@"button ended");
				[self inputDidEnd];
				_trackedTouch = 0;
				break;
			}
		}
	}
}
#else // OS X

-(void) mouseDown:(NSEvent*)event
{
	if (self.enabled)
	{
		if ([self.node containsPoint:[event locationInNode:self.node.parent]])
		{
			[self beginSelect];
		}
	}
}

-(void) mouseDragged:(NSEvent*)event
{
	if (self.enabled)
	{
		BOOL lostFocus = YES;
		if ([self.node containsPoint:[event locationInNode:self.node.parent]])
		{
			lostFocus = NO;
		}
		
		[self inputDidMoveLoseFocus:lostFocus];
	}
}

-(void) mouseUp:(NSEvent*)event
{
	[self inputDidEnd];
}

#endif

@dynamic continuous;
-(void) setContinuous:(BOOL)continuous
{
	if (_continuous != continuous)
	{
		_continuous = continuous;
		if (_continuous)
		{
			[self.node.kkScene addSceneEventsObserver:self];
		}
		else
		{
			[self.node.kkScene removeSceneEventsObserver:self];
		}
	}
}

-(void) update:(NSTimeInterval)currentTime
{
	if (_selected)
	{
		[self execute];
	}
}


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
static NSString* const ArchiveKeyForContinuous = @"continous";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	if (self)
	{
		_originalXScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalXScale];
		_originalYScale = [decoder decodeDoubleForKey:ArchiveKeyForOriginalYScale];
		_selectedScale = [decoder decodeDoubleForKey:ArchiveKeyForFocusScale];
		_selected = [decoder decodeBoolForKey:ArchiveKeyForHasFocus];
		_originalTexture = [decoder decodeObjectForKey:ArchiveKeyForOriginalTexture];
		_selectedTexture = [decoder decodeObjectForKey:ArchiveKeyForSelectedTexture];
		_executesWhenPressed = [decoder decodeBoolForKey:ArchiveKeyForExecutesWhenPressed];
		_continuous = [decoder decodeBoolForKey:ArchiveKeyForContinuous];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeDouble:_originalXScale forKey:ArchiveKeyForOriginalXScale];
	[encoder encodeDouble:_originalYScale forKey:ArchiveKeyForOriginalYScale];
	[encoder encodeDouble:_selectedScale forKey:ArchiveKeyForFocusScale];
	[encoder encodeBool:_selected forKey:ArchiveKeyForHasFocus];
	[encoder encodeObject:_originalTexture forKey:ArchiveKeyForOriginalTexture];
	[encoder encodeObject:_selectedTexture forKey:ArchiveKeyForSelectedTexture];
	[encoder encodeBool:_executesWhenPressed forKey:ArchiveKeyForExecutesWhenPressed];
	[encoder encodeBool:_continuous forKey:ArchiveKeyForContinuous];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKButtonBehavior* copy = [[super copyWithZone:zone] init];
	copy->_originalXScale = _originalXScale;
	copy->_originalYScale = _originalYScale;
	copy->_selectedScale = _selectedScale;
	copy->_selected = _selected;
	copy->_originalTexture = _originalTexture;
	copy->_selectedTexture = _selectedTexture;
	copy->_executesWhenPressed = _executesWhenPressed;
	copy->_continuous = _continuous;
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
			_selected == behavior->_selected &&
			_originalTexture == behavior->_originalTexture &&
			_selectedTexture == behavior->_selectedTexture &&
			_executesWhenPressed == behavior->_executesWhenPressed);
}

@end
