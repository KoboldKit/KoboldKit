/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKViewController.h"
#import "SKNode+KoboldKit.h"
#import "KKView.h"
#import "KKVersion.h"
#import "KKSwizzle.h"

@implementation KKViewController

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
	
	// method swizzling, see: http://cocoadev.com/MethodSwizzling
	[KKSwizzle swizzleMethods];
	
	// using NSClassFromString avoids importing the headers from the subproject,
	// which would cause a circular import situation in Mac builds
	[NSClassFromString(@"KKCommunitySwizzle") swizzleMethods];
	[NSClassFromString(@"KKProSwizzle") swizzleMethods];

	NSAssert1([self.kkView isKindOfClass:[KKView class]],
			  @"KKViewController: view must be of class KKView, but its class is: %@. You may need to change this in your code or in Interface Builder (Identity Inspector -> Custom Class).",
			  NSStringFromClass([self.kkView class]));
}

-(void) viewWillLayoutSubviews
{
#if TARGET_OS_IPHONE
	[super viewWillLayoutSubviews];
#endif

	if (((SKView*)self.view).scene == nil)
	{
		NSLog(@"%@", koboldKitVersion());
		[self presentFirstScene];
	}
}

-(void) presentFirstScene
{
	KKMustOverrideMethod();
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
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
	{
        return UIInterfaceOrientationMaskLandscape;
    }
	else
	{
        return UIInterfaceOrientationMaskAll;
    }
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
#endif

@end
