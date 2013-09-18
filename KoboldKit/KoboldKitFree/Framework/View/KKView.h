/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKFramework.h"

@class KKScene;
@class KKModel;

/** Kobold Kit apps use KKView as their view. It provides additional features like the ability to push & pop scenes. */
@interface KKView : SKView
{
	@private
	NSMutableArray* _sceneStack;
}

/** @name Presenting Scenes */

/** The scenes currently suspended in the background.
 
 After the first call to presentScene it will always contains at least the scene that's currently presented. 
 If sceneStack.count returns 1 then there are currently no scenes in the background.
 @returns An array with 1 or more scenes currently suspended. The presented scene is always the lastObject. */
@property (atomic, readonly) NSArray* sceneStack;

/** Model of the view, can be used to store values and objects whose lifetime should be equal to that of the view (ie global values/objects).
 ®returns The view's model object. */
@property (atomic, readonly) KKModel* model;

/** This returns the EAGLContext for the view using a public API call. This enables custom OpenGL code on the Sprite Kit GL context.
 Note: the context is not valid (is nil) before the view controller's viewDidAppear: method runs. In other words the viewDidAppear: method
 is the earliest point where you will get a valid EAGLContext.
 @returns The view's EAGLContext, or nil if the view controller's viewDidAppear method hasn't run yet. */
@property (atomic, readonly) KKGLContext* context;

/** If YES, will render physics shape outlines. */
@property (atomic) BOOL showsPhysicsShapes;
/** If YES, will render node outlines according to their frame property. */
@property (atomic) BOOL showsNodeFrames;
/** If YES, will render a dot on the node's position. */
@property (atomic) BOOL showsNodeAnchorPoints;

/** @returns Whether physics shape outlines are drawn. */
+(BOOL) showsPhysicsShapes;
/** @returns Whether node frame outlines are drawn. */
+(BOOL) showsNodeFrames;
/** @returns Whether node positions are drawn. */
+(BOOL) showsNodeAnchorPoints;

/** Presents a scene. 
 
 Replaces the topmost scene on the scene stack.
 @param scene The scene to present. */
-(void) presentScene:(SKScene *)scene;

/** Presents a scene.
 
 Replaces the topmost scene on the scene stack.
 @param scene The scene to present.
 @param transition A transition used to animate between the two scenes. */
-(void) presentScene:(SKScene *)scene transition:(SKTransition *)transition;

/** Presents a scene.
 
 If unwindSceneStack is YES, all scenes will be removed from the scene stack before presenting the new scene.
 @param scene The scene to present. 
 @param unwindStack If YES removes all scenes from the stack before adding the new scene. */
-(void) presentScene:(KKScene *)scene unwindStack:(BOOL)unwindStack;

/** Presents a scene.
 
 Replaces the topmost scene on the scene stack.
 @param scene The scene to present.
 @param transition A transition used to animate between the two scenes.
 @param unwindStack If YES removes all scenes from the stack before adding the new scene. */
-(void) presentScene:(KKScene *)scene transition:(KKTransition *)transition unwindStack:(BOOL)unwindStack;

/** Presents a scene, suspends the currently presented scene. 
 
 The currently presented scene will be suspended, stops animating but remains in memory. It can be presented again using one of the popScene methods.
 @param scene The scene to present. */
-(void) pushScene:(KKScene*)scene;

/** Presents a scene, suspends the currently presented scene.
 
 The currently presented scene will be suspended, stops animating but remains in memory. It can be presented again using one of the popScene methods.
 @param scene The scene to present.
 @param transition A transition used to animate between the two scenes. */
-(void) pushScene:(KKScene*)scene transition:(KKTransition*)transition;

/** Pops the topmost scene from the stack and presents the new topmost scene.
 
 If there is only one scene on the stack (the currently presented scene) then this method has no effect. */
-(void) popScene;

/** Pops the topmost scene from the stack and presents the new topmost scene.
 
 If there is only one scene on the stack (the currently presented scene) then this method has no effect.
 @param transition A transition used to animate between the two scenes. */
-(void) popSceneWithTransition:(KKTransition*)transition;

/** Pops all scenes from the stack except for the root scene, then presents the root scene.
 
 If there is only one scene on the stack (the currently presented scene) then this method has no effect. */
-(void) popToRootScene;

/** Pops all scenes from the stack except for the root scene, then presents the root scene.
 
 If there is only one scene on the stack (the currently presented scene) then this method has no effect.
 @param transition A transition used to animate between the two scenes. */
-(void) popToRootSceneWithTransition:(KKTransition*)transition;

/** Searches for the first scene with the given name in the scene stack and presents it.
 
 If there is no scene by this name on the scene stack, then this method has no effect.
 @param name The name of a scene on the stack to be presented. */
-(void) popToSceneNamed:(NSString*)name;

/** Searches for the first scene with the given name in the scene stack and presents it.
 
 If there is no scene by this name on the scene stack, then this method has no effect.
 @param name The name of a scene on the stack to be presented.
 @param transition A transition used to animate between the two scenes. */
-(void) popToSceneNamed:(NSString*)name transition:(KKTransition*)transition;

/** Reloads the config files, replacing the existing "config" and "devconfig" entries in the model. */
-(void) reloadConfig;

@end
