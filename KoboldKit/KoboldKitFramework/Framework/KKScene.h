//
//  KKScene.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "KKSceneEventDelegate.h"

@class KKNodeController;
@class KKView;
@class KKPhysicsDebugNode;

/** Scene Graph dump options. */
typedef enum
{
	KKSceneGraphDumpAll = 0,
} KKSceneGraphDumpOptions;

typedef enum
{
	KKMainLoopStageInit = 0,
	KKMainLoopStageDidUpdate,
	KKMainLoopStageDidEvaluateActions,
	KKMainLoopStageDidSimulatePhysics,
} KKMainLoopStage;

/** KKScene is the scene class used in Kobold Kit projects. KKScene updates the controllers and behaviors, receives and
 dispatches events (input, physics).*/
@interface KKScene : SKScene <SKPhysicsContactDelegate, KKSceneEventDelegate>
{
	@private
	NSMutableArray* _controllers;
	NSMutableArray* _inputObservers;
	NSMutableArray* _sceneUpdateObservers;
	NSMutableArray* _sceneDidUpdateBehaviorsObservers;
	NSMutableArray* _sceneDidEvaluateActionsObservers;
	NSMutableArray* _sceneDidSimulatePhysicsObservers;
	NSMutableArray* _sceneWillMoveFromViewObservers;
	NSMutableArray* _sceneDidMoveToViewObservers;
	
	// used to detect missing super calls
	KKMainLoopStage _mainLoopStage;
}

/** @returns The number of frames rendered since the start of the app. Useful if you need to lock your game's update cycle to the framerate.
 For example this allows you to perform certain actions n frames from now, instead of n seconds. */
@property (atomic) NSUInteger frameCount;

/** @returns The view cast to a KKView object. */
@property (atomic, readonly) KKView* kkView;

/** (not documented) */
-(void) addSceneEventsObserver:(id)observer;
/** (not documented) */
-(void) removeSceneEventsObserver:(id)observer;

/** Registers a class as generic input receiver. Implement the usual input event methods on the receiver.
 Note: this is a preliminary, inefficient system. It will eventually be replaced.
 @param receiver Any object that implements touch, mouse, or other input events. */
-(void) addInputEventsObserver:(id)observer;
/** Unregisters a class as generic input receiver.
 @param receiver An object that was previously registered as input receiver. */
-(void) removeInputEventsObserver:(id)observer;

// internal use
-(BOOL) isEqualToScene:(KKScene*)scene;
-(BOOL) isEqualToSceneTree:(KKScene*)scene;
-(BOOL) isEqualToSceneProperties:(KKScene*)scene;

/** Dumps the scene graph to a string.
 @param options Determines what will be included in the dump.
 @returns A string containing the textual dump of the scene graph. */
-(NSString*) dumpSceneGraph:(KKSceneGraphDumpOptions)options;


// internal use
-(void) registerController:(KKNodeController*)controller;
-(void) unregisterController:(KKNodeController*)controller;

@end
