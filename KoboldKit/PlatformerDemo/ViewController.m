//
//  ViewController.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"
#import "MenuScene.h"

@implementation ViewController

-(void) presentFirstScene
{
	[super presentFirstScene];
	
    // Create and configure the scene.
	KKScene* scene = [MenuScene sceneWithSize:self.view.bounds.size];
	//KKScene* scene = [GameScene sceneWithSize:self.view.bounds.size];
    
    // Present the scene.
    [self.kkView presentScene:scene];
}

@end
