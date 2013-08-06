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
	
    // Create and present the scene.
	//KKScene* scene = [MenuScene sceneWithSize:self.view.bounds.size];
	//[self.kkView presentScene:scene];
	
	GameScene* gameScene = [GameScene sceneWithSize:self.view.bounds.size];
	gameScene.tmxFile = @"DemoLevel01_Steffen.tmx";
	[self.kkView presentScene:gameScene transition:[SKTransition fadeWithColor:[SKColor grayColor] duration:0.5]];
}

@end
