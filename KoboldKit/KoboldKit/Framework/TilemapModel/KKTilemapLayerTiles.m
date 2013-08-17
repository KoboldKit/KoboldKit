//
// KTTilemapLayerTiles.m
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 20.12.12.
//
//



#import "KKTilemapLayerTiles.h"
#import "KKTilemap.h"

@implementation KKTilemapLayerTiles

-(void) takeOwnershipOfGidBuffer:(gid_t*)tiles bufferSize:(unsigned int)bufferSize
{
	free(_gid);
	_gid = tiles;
	_gidSize = bufferSize;
	_gidCount = bufferSize / sizeof(gid_t);
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

