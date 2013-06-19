//
//  KKSceneEventDelegate.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 15.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKSpriteKit.h"

/** Informal protocol defining the "update" methods an object can implement and receive when subscribed
 to updates in the scene. */
@protocol KKSceneEventDelegate <NSObject>
@optional
/** (not documented) */
-(void) update:(NSTimeInterval)currentTime;
/** (not documented) */
-(void) didUpdateBehaviors;
/** (not documented) */
-(void) didEvaluateActions;
/** (not documented) */
-(void) didSimulatePhysics;
/** (not documented) */
-(void) willMoveFromView:(SKView*)view;
/** (not documented) */
-(void) didMoveToView:(SKView*)view;
/** (not documented) */
-(void) didChangeSize:(CGSize)oldSize;
@end
