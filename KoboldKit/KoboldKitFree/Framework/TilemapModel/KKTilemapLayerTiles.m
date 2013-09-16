/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTilemapLayerTiles.h"
#import "KKTilemap.h"

@implementation KKTilemapLayerTiles

-(void) retainGidBuffer:(gid_t*)gid sizeInBytes:(unsigned int)sizeInBytes
{
	free(_gid);
	_gid = gid;
	_bytes = sizeInBytes;
	_count = sizeInBytes / sizeof(gid_t);
}

-(id) initWithCoder:(NSCoder*)aDecoder
{
	if ((self = [super init]))
	{
	}

	return self;
}

-(void) encodeWithCoder:(NSCoder*)aCoder
{
}

-(void) dealloc
{
	free(_gid);
	_gid = nil;
}

@end

