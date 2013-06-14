//
// NSCoder+KTCoderCategory.h
// Kobold2D-Libraries
//
// Created by Steffen Itterheim on 11.10.12.
//
//

#import <Foundation/Foundation.h>

/** Adds encode/decode convenience methods for common structs not supported natively (or cross-platform) by NSCoder. */
@interface NSCoder (KTCoderCategory)

#if KK_PLATFORM_IOS
/** encode a CGPoint */
-(void) encodePoint:(CGPoint)point forKey:(NSString*)key;
/** decode a CGPoint */
-(CGPoint) decodePointForKey:(NSString*)key;
#elif KK_PLATFORM_MAC
/** encode a CGPoint on OS X */
-(void) encodeCGPoint:(CGPoint)point forKey:(NSString*)key;
/** decode a CGPoint on OS X */
-(CGPoint) decodeCGPointForKey:(NSString*)key;
#endif /* if KK_PLATFORM_IOS */

@end
