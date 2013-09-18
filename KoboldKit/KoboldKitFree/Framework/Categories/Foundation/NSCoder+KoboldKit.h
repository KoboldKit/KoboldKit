/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <Foundation/Foundation.h>

/** Adds encode/decode convenience methods for common structs not supported natively (or cross-platform) by NSCoder. */
@interface NSCoder (KoboldKit)

#if TARGET_OS_IPHONE
/** Encodes a CGPoint.
 @param point The point to encode.
 @param key The archive key. */
-(void) encodePoint:(CGPoint)point forKey:(NSString*)key;
/** Decodes a CGPoint
 @returns The decoded point.
 @param key The archive key. */
-(CGPoint) decodePointForKey:(NSString*)key;
#else
/** Encodes a CGPoint using the same method defined by UIGeometry.h on iOS. 
 @param point The point to encode.
 @param key The archive key. */
-(void) encodeCGPoint:(CGPoint)point forKey:(NSString*)key;
/** Decodes a CGPoint using the same method defined by UIGeometry.h on iOS.
 @returns The decoded point.
 @param key The archive key. */
-(CGPoint) decodeCGPointForKey:(NSString*)key;
#endif

@end
