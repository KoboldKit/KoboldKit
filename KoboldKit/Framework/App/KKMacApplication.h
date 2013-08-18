//
//  KKMacApplication.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 09.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKFramework.h"

/** Kobold Kit Mac OS X application object inheriting from NSApplication. This must be set as the app's principal class.
 This class mainly exists to fix an issue with keyboard input where key up events are not received when the Command key is pressed. */
#if !TARGET_OS_IPHONE
@interface KKMacApplication : NSApplication

@end
#endif
