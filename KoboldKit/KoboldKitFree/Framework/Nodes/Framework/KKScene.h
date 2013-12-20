/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import <SpriteKit/SpriteKit.h>
#import "KKSceneEventDelegate.h"
#import "KKPhysicsContactEventDelegate.h"
#import "KKInputEventDelegate.h"

@class KKNodeController;
@class KKView;

/** Scene Graph dump options. */
typedef NS_ENUM(NSUInteger, KKSceneGraphDumpOptions)
{
	KKSceneGraphDumpAll = 0,
};

// internal use
typedef NS_ENUM(NSUInteger, KKMainLoopStage)
{
	KKMainLoopStageInit = 0,
	KKMainLoopStageDidUpdate,
	KKMainLoopStageDidEvaluateActions,
	KKMainLoopStageDidSimulatePhysics,
};

/** KKScene is the scene class used in Kobold Kit projects. KKScene updates the controllers and behaviors, receives and
 dispatches events (input, physics). */
@interface KKScene : SKScene <SKPhysicsContactDelegate, KKSceneEventDelegate>
{
	@private
	NSMutableArray* _inputObservers;
	
	NSMutableArray* _sceneUpdateObservers;
	NSMutableArray* _sceneDidEvaluateActionsObservers;
	NSMutableArray* _sceneDidSimulatePhysicsObservers;
	NSMutableArray* _sceneWillMoveFromViewObservers;
	NSMutableArray* _sceneDidMoveToViewObservers;
	
	NSMutableArray* _physicsContactObservers;
	
	// used to detect missing super calls
	KKMainLoopStage _mainLoopStage;
}

/** @returns The number of frames rendered since the start of the app. Useful if you need to lock your game's update cycle to the framerate.
 For example this allows you to perform certain actions n frames from now, instead of n seconds. */
@property (atomic) NSUInteger frameCount;

/** @returns The view cast to a KKView object. */
@property (atomic, readonly) KKView* kkView;

/** Adds a scene event observer.
 @param observer The receiver of scene events. */
-(void) addSceneEventsObserver:(id<KKSceneEventDelegate>)observer;
/** Removes a scene event observer.
  @param observer The receiver of scene events. */
-(void) removeSceneEventsObserver:(id<KKSceneEventDelegate>)observer;

/** Adds a physics contact event observer.
 @param observer The receiver of scene events. */
-(void) addPhysicsContactEventsObserver:(id<KKPhysicsContactEventDelegate>)observer;
/** Removes a physics contact event observer.
 @param observer The receiver of scene events. */
-(void) removePhysicsContactEventsObserver:(id<KKPhysicsContactEventDelegate>)observer;

/** Registers a class as generic input receiver. Implement the usual input event methods on the receiver.
 Note: this is a preliminary, inefficient system. It will eventually be replaced.
 @param observer Any object that implements touch, mouse, or other input events. */
-(void) addInputEventsObserver:(id)observer;
/** Unregisters a class as generic input receiver.
 @param observer An object that was previously registered as input receiver. */
-(void) removeInputEventsObserver:(id)observer;

/** Dumps the scene graph to a string.
 @param options Determines what will be included in the dump.
 @returns A string containing the textual dump of the scene graph. */
-(NSString*) dumpSceneGraph:(KKSceneGraphDumpOptions)options;


// internal use
-(BOOL) isEqualToScene:(KKScene*)scene;
-(BOOL) isEqualToSceneTree:(KKScene*)scene;
-(BOOL) isEqualToSceneProperties:(KKScene*)scene;

@end
