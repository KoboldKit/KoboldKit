/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"

/** Kobold Kit Mac OS X application object inheriting from NSApplication. This must be set as the app's principal class.
 This class mainly exists to fix an issue with keyboard input where key up events are not received when the Command key is pressed. */
#if !TARGET_OS_IPHONE
@interface KKMacApplication : NSApplication

@end
#endif
