//
//  KKViewController.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKCompatibility.h"

@class KKView;

/** View controller for a Kobold Kit view. Creates the KKView and performs other setup tasks. */
#if TARGET_OS_IPHONE
@interface KKViewController : UIViewController
#else
@interface KKViewController : NSViewController
#endif

/** @returns The view controller's view cast to KKView. Use this property to use the KKView methods and properties. */
@property (atomic, readonly) KKView* kkView;

-(void) viewDidLoad;
-(void) viewDidAppear:(BOOL)animated;

/** Called when the view is ready to present the first scene. */
-(void) presentFirstScene;

@end
