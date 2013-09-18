/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "NSCoder+KoboldKit.h"

@implementation NSCoder (KoboldKit)

#if TARGET_OS_IPHONE

-(void) encodePoint:(CGPoint)point forKey:(NSString*)key
{
	[self encodeCGPoint:point forKey:key];
}

-(CGPoint) decodePointForKey:(NSString*)key
{
	return [self decodeCGPointForKey:key];
}

#else

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
