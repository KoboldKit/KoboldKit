//
//  KKAppDelegate.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 09.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKCompatibility.h"
#import "KKView.h"
#import "KKViewController.h"

#if TARGET_OS_IPHONE
@interface KKAppDelegate : UIResponder <UIApplicationDelegate>
#else
@interface KKAppDelegate : NSResponder <NSApplicationDelegate>
#endif

@property (strong, nonatomic) IBOutlet KKWindow* window;
@property (weak) IBOutlet KKView *kkView;

#if !TARGET_OS_IPHONE
@property (strong) KKViewController* viewController;
#endif

@end
