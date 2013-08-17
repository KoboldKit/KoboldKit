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
	
	MenuScene* menuScene = [MenuScene sceneWithSize:self.view.bounds.size];
	[self.kkView presentScene:menuScene];
	
	/*
    // Create and present the first scene
	GameScene *gameScene = [GameScene sceneWithSize:self.view.bounds.size];
	gameScene.tmxFile = @"DemoStage003.tmx";
	SKTransition *transition = [SKTransition fadeWithColor:[SKColor grayColor] duration:0.5];
	[self.kkView presentScene:gameScene transition:transition];
	 */
}

@end