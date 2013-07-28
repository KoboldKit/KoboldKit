//
//  NSObject+KoboldKit.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 28.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

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
