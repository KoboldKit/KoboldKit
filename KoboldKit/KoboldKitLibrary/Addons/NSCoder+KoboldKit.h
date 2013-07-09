//
//
// Created by Steffen Itterheim on 11.10.12.
//
//

#import <Foundation/Foundation.h>

/** Adds encode/decode convenience methods for common structs not supported natively (or cross-platform) by NSCoder. */
@interface NSCoder (KoboldKit)

#if TARGET_OS_IPHONE
/** encode a CGPoint */
-(void) encodePoint:(CGPoint)point forKey:(NSString*)key;
/** decode a CGPoint */
-(CGPoint) decodePointForKey:(NSString*)key;
#else
/** encode a CGPoint on OS X */
-(void) encodeCGPoint:(CGPoint)point forKey:(NSString*)key;
/** decode a CGPoint on OS X */
-(CGPoint) decodeCGPointForKey:(NSString*)key;
#endif /* if TARGET_OS_IPHONE */

@end
