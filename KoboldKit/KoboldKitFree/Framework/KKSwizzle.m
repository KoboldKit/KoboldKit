/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKSwizzle.h"
#import "KKCategories.h"

@implementation KKSwizzle

+(void) checkSwizzleError:(NSError*)error
{
	NSAssert1(error == nil, @"Method swizzling error: %@", error);
}

+(void) swizzleMethods
{
	// For more info on method swizzling see: http://cocoadev.com/MethodSwizzling

	// perform any Sprite Kit / Kobold Kit method swizzling here
	// PS: try to avoid swizzling when possible.

	/*
	 // swizzle some methods to hook into Sprite Kit
	 NSError* error;
	 
	 [SKNode jr_swizzleMethod:@selector(copyWithZone:) withMethod:@selector(kkCopyWithZone:) error:&error];
	 [self checkSwizzleError:error];
	 */
}

@end
