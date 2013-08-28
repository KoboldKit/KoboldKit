/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "NSObject+KoboldKit.h"

@implementation NSObject (KoboldKit)


#pragma mark Perform Selector

-(void) performSelector:(SEL)aSelector afterDelay:(NSTimeInterval)delay
{
	[self performSelector:aSelector withObject:self afterDelay:delay];
}

-(void) performSelectorInBackground:(SEL)aSelector
{
	[self performSelectorInBackground:aSelector withObject:self];
}

@end
