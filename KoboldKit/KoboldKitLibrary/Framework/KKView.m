//
//  KKView.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 14.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKView.h"
#import "KKScene.h"
#import "KKModel.h"

#define ASSERT_SCENE_STACK_INTEGRITY() NSAssert2([_sceneStack lastObject] == self.scene, @"scene stack out of synch! Presented scene: %@ - topmost scene on stack: %@", self.scene, [_sceneStack lastObject])

@implementation KKView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		[self initDefaults];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self initDefaults];
	}
	return self;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		[self initDefaults];
	}
	return self;
}

-(void) initDefaults
{
	_sceneStack = [NSMutableArray array];
	_model = [[KKModel alloc] init];
}

#pragma mark Present Scene

-(void) presentScene:(SKScene *)scene
{
	[self presentScene:scene transition:nil];
}

-(void) presentScene:(SKScene *)scene transition:(SKTransition *)transition
{
	if (_sceneStack.count > 0)
	{
		[_sceneStack removeLastObject];
	}
	[_sceneStack addObject:scene];
	
	transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
	ASSERT_SCENE_STACK_INTEGRITY();
}

-(void) presentScene:(KKScene *)scene unwindStack:(BOOL)unwindStack
{
	[self presentScene:scene transition:nil unwindStack:unwindStack];
}

-(void) presentScene:(KKScene *)scene transition:(KKTransition *)transition unwindStack:(BOOL)unwindStack
{
	if (unwindStack)
	{
		[_sceneStack removeAllObjects];
		[_sceneStack addObject:scene];
	}
	transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
	ASSERT_SCENE_STACK_INTEGRITY();
}

-(void) pushScene:(KKScene*)scene
{
	[self pushScene:scene transition:nil];
}

-(void) pushScene:(KKScene*)scene transition:(KKTransition*)transition
{
	[_sceneStack addObject:self.scene];
	transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
	ASSERT_SCENE_STACK_INTEGRITY();
}

-(void) popScene
{
	[self popSceneWithTransition:nil];
}

-(void) popSceneWithTransition:(KKTransition*)transition
{
	if (_sceneStack.count > 1)
	{
		KKScene* scene = [_sceneStack lastObject];
		if (scene)
		{
			[_sceneStack removeLastObject];
			transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
			ASSERT_SCENE_STACK_INTEGRITY();
		}
	}
}

-(void) popToRootScene
{
	[self popToRootSceneWithTransition:nil];
}

-(void) popToRootSceneWithTransition:(KKTransition*)transition
{
	if (_sceneStack.count > 1)
	{
		KKScene* scene = [_sceneStack firstObject];
		if (scene)
		{
			[_sceneStack removeAllObjects];
			[_sceneStack addObject:scene];
			transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
			ASSERT_SCENE_STACK_INTEGRITY();
		}
	}
}

-(void) popToSceneNamed:(NSString*)name
{
	[self popToSceneNamed:name transition:nil];
}

-(void) popToSceneNamed:(NSString*)name transition:(KKTransition*)transition
{
	if (_sceneStack.count > 1)
	{
		NSMutableIndexSet* indexes = [NSMutableIndexSet indexSet];
		for (NSUInteger i = _sceneStack.count - 2; i == 0; i--)
		{
			[indexes addIndex:i];
			KKScene* scene = [_sceneStack objectAtIndex:i];
			if ([scene.name isEqualToString:name])
			{
				[_sceneStack removeObjectsAtIndexes:indexes];
				[_sceneStack addObject:scene];
				transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
				ASSERT_SCENE_STACK_INTEGRITY();
				break;
			}
		}
	}
}

@end
