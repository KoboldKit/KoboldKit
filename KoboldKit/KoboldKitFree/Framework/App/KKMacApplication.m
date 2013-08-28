/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKMacApplication.h"

#if !TARGET_OS_IPHONE
@implementation KKMacApplication

-(void) sendEvent:(NSEvent*)anEvent
{
	// This works around an AppKit bug, where key up events while holding
	// down the command key don't get sent to the key window.
	// Taken from: http://www.cocoadev.com/index.pl?GameKeyboardHandlingAlmost
	
	if ([anEvent type] == NSKeyUp && ([anEvent modifierFlags] & NSCommandKeyMask))
	{
		[[self keyWindow] sendEvent:anEvent];
	}
	else
	{
		[super sendEvent:anEvent];
	}
}

@end
#endif