/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"

@class KKView;

/** View controller for a Kobold Kit view, supposed to be subclassed by user for the Kobold Kit view controller & view. 
 Creates the KKView and performs other setup tasks. Combines code for both iOS & OS X platforms to a single uniform controller. */
#if TARGET_OS_IPHONE
@interface KKViewController : UIViewController
#else
@interface KKViewController : NSViewController

/** Called after view did load. Declaration needed for Mac OS X whose NSViewController knows no viewDidLoad method. */
-(void) viewDidLoad;

#endif

/** @returns The view controller's view cast to KKView. Use this property to use the KKView methods and properties. */
@property (atomic, readonly) KKView* kkView;

/** Called when the view is ready to present the first scene. Override in your subclass to present the very first scene. */
-(void) presentFirstScene;

@end
