//
// NSCoder+KTCoderCategory.m
// Kobold2D-Libraries
//
// Created by Steffen Itterheim on 11.10.12.
//
//

#import "NSCoder+KTCoderCategory.h"

@implementation NSCoder (KTCoderCategory)

#if TARGET_OS_IPHONE
-(void) encodePoint:(CGPoint)point forKey:(NSString*)key
{
	[self encodeCGPoint:point forKey:key];
}

-(CGPoint) decodePointForKey:(NSString*)key
{
	return [self decodeCGPointForKey:key];
}

#elif TARGET_OS_MAC
-(void) encodeCGPoint:(CGPoint)point forKey:(NSString*)key
{
	[self encodePoint:point forKey:key];
}

-(CGPoint) decodeCGPointForKey:(NSString*)key
{
	return [self decodePointForKey:key];
}

#endif /* if TARGET_OS_IPHONE */

@end
