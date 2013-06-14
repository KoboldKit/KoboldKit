//
//  KKView.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 14.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteKit.h"

@class KKScene;

@interface KKView : SKView
{
	@private
	NSMutableArray* _sceneStack;
}

@property (atomic, readonly) NSArray* sceneStack;

-(void) pushScene:(KKScene*)scene;
-(void) pushScene:(KKScene*)scene transition:(KKTransition*)transition;
-(void) popScene;
-(void) popSceneWithTransition:(KKTransition*)transition;
-(void) popAllScenes;
-(void) popAllScenesWithTransition:(KKTransition*)transition;

@end
