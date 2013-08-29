/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKViewController.h"
#import "SKNode+KoboldKit.h"
#import "KKView.h"
#import "KKVersion.h"

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
	
	[self swizzleMethods];

	NSAssert1([self.kkView isKindOfClass:[KKView class]],
			  @"KKViewController: view must be of class KKView, but its class is: %@. You may need to change this in your code or in Interface Builder (Identity Inspector -> Custom Class).",
			  NSStringFromClass([self.kkView class]));
}

-(void) viewWillLayoutSubviews
{
#if TARGET_OS_IPHONE
	[super viewWillLayoutSubviews];
#endif

	if (_firstScenePresented == NO)
	{
		_firstScenePresented = YES;
		
		NSLog(@"%@", koboldKitVersion());
		[self presentFirstScene];
	}
}

-(void) presentFirstScene
{
	KKMustOverrideMethod();
}

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
