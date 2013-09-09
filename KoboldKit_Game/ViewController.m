/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <KoboldKit.h>
#import "ViewController.h"
#import "MyScene.h"

@implementation ViewController

-(void) presentFirstScene
{
	NSLog(@"%@", koboldKitCommunityVersion());
	NSLog(@"%@", koboldKitProVersion());

	// create and present first scene
	MyScene* myScene = [MyScene sceneWithSize:self.view.bounds.size];
	[self.kkView presentScene:myScene];
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	// EAGLContext is not valid before viewDidAppear
	id context = self.kkView.context;
	NSLog(@"EAGLContext = %@", context);
}

@end
