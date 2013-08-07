//
//  NSString+KoboldKit.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 28.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "NSString+KoboldKit.h"

@implementation NSString (KoboldKit)

-(CGRect) rectValue
{
#if TARGET_OS_IPHONE
	CGRect rect = CGRectFromString(self);
	return rect;
#else
	NSRect rect = NSRectFromString(self);
	return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
#endif
}

-(CGSize) sizeValue
{
#if TARGET_OS_IPHONE
	CGSize size = CGSizeFromString(self);
	return size;
#else
	NSSize size = NSSizeFromString(self);
	return CGSizeMake(size.width, size.height);
#endif
}

-(CGPoint) pointValue
{
#if TARGET_OS_IPHONE
	CGPoint point = CGPointFromString(self);
	return point;
#else
	NSPoint point = NSPointFromString(self);
	return CGPointMake(point.x, point.y);
#endif
}

-(SKColor*) color
{
	CIColor* ciColor = [CIColor colorWithString:self];
	SKColor* skColor = [SKColor colorWithCIColor:ciColor];
	return skColor;
}

-(BOOL) containsString:(NSString*)subString
{
	return ([self rangeOfString:subString].location != NSNotFound);
}


@end
