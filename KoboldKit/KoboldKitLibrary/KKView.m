//
//  KKView.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 14.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKView.h"
#import "KKScene.h"

@implementation KKView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		_sceneStack = [NSMutableArray array];
    }
    return self;
}

-(void) pushScene:(KKScene*)scene
{
	[_sceneStack addObject:self.scene];
	[self presentScene:scene];
}

-(void) pushScene:(KKScene*)scene transition:(KKTransition*)transition
{
	[_sceneStack addObject:self.scene];
	[self presentScene:scene transition:transition];
}

-(void) popScene
{
	KKScene* scene = [_sceneStack lastObject];
	if (scene)
	{
		[_sceneStack removeLastObject];
		[self presentScene:scene];
	}
}

-(void) popSceneWithTransition:(KKTransition*)transition
{
	KKScene* scene = [_sceneStack lastObject];
	if (scene)
	{
		[_sceneStack removeLastObject];
		[self presentScene:scene transition:transition];
	}
}

-(void) popAllScenes
{
	KKScene* scene = [_sceneStack firstObject];
	if (scene)
	{
		[_sceneStack removeAllObjects];
		[self presentScene:scene];
	}
}

-(void) popAllScenesWithTransition:(KKTransition*)transition
{
	KKScene* scene = [_sceneStack firstObject];
	if (scene)
	{
		[_sceneStack removeAllObjects];
		[self presentScene:scene transition:transition];
	}
}

@end
