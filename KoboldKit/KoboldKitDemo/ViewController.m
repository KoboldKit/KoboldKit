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

#if TARGET_OS_IPHONE

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

	LOG_EXPR(self.view.bounds.size);
	
    // Create and configure the scene.
	KKScene* scene = [MenuScene sceneWithSize:self.view.bounds.size];
	//KKScene* scene = [GameScene sceneWithSize:self.view.bounds.size];
    
    // Present the scene.
    [self.kkView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#else // Mac OS X

#endif

@end
