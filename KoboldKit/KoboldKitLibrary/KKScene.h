//
//  KKScene.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class KKNodeController;

/** Scene Graph dump options. */
typedef enum
{
	KKSceneGraphDumpAll = 0,
} KKSceneGraphDumpOptions;

/** KKScene is the scene class used in Kobold Kit projects. KKScene updates the controllers and behaviors, receives and
 dispatches events (input, physics).*/
@interface KKScene : SKScene <SKPhysicsContactDelegate>
{
	@private
	NSMutableArray* _controllers;
	NSMutableArray* _inputReceivers;
}

/** @returns The number of frames rendered since the start of the app. Useful if you need to lock your game's update cycle to the framerate.
 For example this allows you to perform certain actions n frames from now, instead of n seconds. */
@property (atomic) NSUInteger frameCount;

-(void) registerController:(KKNodeController*)controller;
-(void) unregisterController:(KKNodeController*)controller;

/** Registers a class as generic input receiver. Implement the usual input event methods on the receiver.
 Note: this is a preliminary, inefficient system. It will eventually be replaced.
 @param receiver Any object that implements touch, mouse, or other input events. */
-(void) registerInputReceiver:(id)receiver;
/** Unregisters a class as generic input receiver.
 @param receiver An object that was previously registered as input receiver. */
-(void) unregisterInputReceiver:(id)receiver;

/** */
-(BOOL) isEqualToScene:(KKScene*)scene;
-(BOOL) isEqualToSceneTree:(KKScene*)scene;
-(BOOL) isEqualToSceneProperties:(KKScene*)scene;

/**
 @returns */
-(NSString*) dumpSceneGraph:(KKSceneGraphDumpOptions)options;

@end
