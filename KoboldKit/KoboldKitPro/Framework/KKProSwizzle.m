/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import "KKProSwizzle.h"
#import "KKProCategories.h"

@implementation KKProSwizzle

+(void) checkSwizzleError:(NSError*)error
{
	NSAssert1(error == nil, @"Method swizzling error: %@", error);
}

+(void) swizzleMethods
{
	// perform any Sprite Kit / Kobold Kit method swizzling here
	NSError* error;
	
	[KKTilemapTileLayerNode jr_swizzleMethod:@selector(updateLayer) withMethod:@selector(kkpro_updateLayer) error:&error];
	[self checkSwizzleError:error];
}

@end
