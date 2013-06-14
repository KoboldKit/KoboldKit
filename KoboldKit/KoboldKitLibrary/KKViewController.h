//
//  KKViewController.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteKit.h"

/** View controller for a Kobold Kit view. Creates the KKView and performs other setup tasks. */
@interface KKViewController : UIViewController
/** @returns The view controller's view cast to KKView. Use this property to use the KKView methods and properties. */
@property (atomic, readonly) KKView* kkView;
@end
