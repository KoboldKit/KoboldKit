/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"

/** Informal protocol defining the "update" methods an object can implement and receive when subscribed
 to updates in the scene. */
@protocol KKSceneEventDelegate <NSObject>

@optional

/** The standard update method.
 @param currentTime The time elapsed since app launch. */
-(void) update:(NSTimeInterval)currentTime;

/** Called after actions have been evaluated. */
-(void) didEvaluateActions;

/** Called after physics world has been simulated. */
-(void) didSimulatePhysics;

/** Called when scene will leave the view.
 @param view The view the scene is leaving. Identical to scene.view. */
-(void) willMoveFromView:(SKView*)view;

/** Called when scene will attach to a view.
 @param view The view the scene is attached to. Identical to scene.view. */
-(void) didMoveToView:(SKView*)view;

/** Called when scene changed its size, ie after rotating or changing views.
 @param oldSize The scene's previous size. The scene.size property contains the new size. */
-(void) didChangeSize:(CGSize)oldSize;

@end


