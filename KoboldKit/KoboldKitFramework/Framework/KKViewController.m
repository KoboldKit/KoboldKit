//
//  KKViewController.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKViewController.h"
#import "SKNode+KoboldKit.h"
#import "KKView.h"
#import "JRSwizzle.h"

@implementation KKViewController

-(void) checkSwizzleError:(NSError*)error
{
	NSAssert1(error == nil, @"Method swizzling error: %@", error);
}

-(void) swizzleMethods
{
	/*
	 // swizzle some methods to hook into Sprite Kit
	 NSError* error;
	 
	 [SKNode jr_swizzleMethod:@selector(copyWithZone:)
	 withMethod:@selector(kkCopyWithZone:) error:&error];
	 [self checkSwizzleError:error];
	 */
}

@dynamic kkView;
-(KKView*) kkView
{
	return (KKView*)self.view;
}

-(void) viewDidLoad
{
#if TARGET_OS_IPHONE
    [super viewDidLoad];
#endif
	
	[self swizzleMethods];
	
    // Configure the view.
	KKView* kkView = (KKView*)self.view;
	NSAssert1([kkView isKindOfClass:[KKView class]],
			  @"KKViewController: view must be of class KKView, but its class is: %@. You may need to change this in your code or in Interface Builder (Identity Inspector -> Custom Class).",
			  NSStringFromClass([kkView class]));
	
#if DEBUG
	kkView.showsFPS = YES;
	kkView.showsDrawCount = YES;
	kkView.showsNodeCount = YES;
#endif
}

-(void) viewDidAppear:(BOOL)animated
{
#if TARGET_OS_IPHONE
    [super viewDidAppear:animated];
#endif
	
	[self presentFirstScene];
}

-(void) presentFirstScene
{
	LOG_EXPR(self.view.bounds.size);
}

#if TARGET_OS_IPHONE
-(BOOL) prefersStatusBarHidden
{
	return YES;
}

-(BOOL) shouldAutorotate
{
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
        return UIInterfaceOrientationMaskLandscape;
    }
	else
	{
        return UIInterfaceOrientationMaskAll;
    }
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
#endif

@end
