/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"
#import "KKView.h"
#import "KKViewController.h"

/** In a Kobold Kit project, the app delegate class should inherit from KKAppDelegate which provides default behaviors.
  Combines code for both iOS & OS X platforms to a single uniform app delegate. In particular on Mac OS X KKAppDelegate sets up the view controller. */
#if TARGET_OS_IPHONE
@interface KKAppDelegate : UIResponder <UIApplicationDelegate>
#else
@interface KKAppDelegate : NSResponder <NSApplicationDelegate>

/** @returns The Kobold Kit view controller. */
@property (strong) KKViewController* viewController;
#endif

/** The window reference. On Mac OS X this is the main window. */
@property (strong, nonatomic) IBOutlet KKWindow* window;
/** Convenience accessor to view cast to KKView. */
@property (weak) IBOutlet KKView *kkView;

@end
