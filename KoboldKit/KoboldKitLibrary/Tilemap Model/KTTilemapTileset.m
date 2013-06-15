//
// KTTilemapTileset.m
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 20.12.12.
//
//


#import "KTTilemapTileset.h"
#import "KTTilemap.h"
#import "KTTilemapProperties.h"
#import "KTTilemapTileProperties.h"
#import "KKSpriteKit.h"

@implementation KTTilemapTileset

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ (name: '%@', image: '%@', firstGid: %i, spacing: %i, margin: %i, tileSize: %.0f,%.0f, num properties: %u)",
			[super description], _name, _imageFile, _firstGid, _spacing, _margin, _tileSize.width, _tileSize.height, (unsigned int)_properties.count];
}

-(NSString*) imageFile
{
	if (_alternateTileset)
	{
		return _alternateTileset.imageFile;
	}

	return _imageFile;
}

static NSArray* kPVRImageFileExtensions = nil;

-(SKTexture*) texture
{
	if (_alternateTileset)
	{
		return _alternateTileset.texture;
	}

	if (_texture == nil)
	{
#pragma message "TODO: tilemap pvr texture load"
		/*
		if (kPVRImageFileExtensions == nil)
		{
			kPVRImageFileExtensions = [NSArray arrayWithObjects:@"pvr.ccz", @"pvr.gz", @"pvr", nil];
		}

		// try loading .pvr.ccz / .pvr / .pvr.gz first and default to imageFile if not found
		NSFileManager* fileManager = [NSFileManager defaultManager];
		CCFileUtils* fileUtils = [CCFileUtils sharedFileUtils];

		for (NSString* fileExtension in kPVRImageFileExtensions)
		{
			NSString* pvrImageFile = [NSString stringWithFormat:@"%@.%@", [_imageFile stringByDeletingPathExtension], fileExtension];
			NSString* pvrImageFilePath = [fileUtils fullPathFromRelativePath:pvrImageFile];
			if ([fileManager fileExistsAtPath:pvrImageFilePath])
			{
				_texture = [[CCTextureCache sharedTextureCache] addImage:pvrImageFile];
				break;
			}
		}
		 */

		// no pvr version of tileset found, load the default tileset image
		if (_texture == nil)
		{
			_texture = [KKTexture textureWithImageNamed:_imageFile];
		}

		NSAssert(_texture, @"could not find (or otherwise load) image file: '%@'", _imageFile);
		[self setupTextureRects];
	}

	return _texture;
} /* texture */

-(void) setupTextureRects
{
	// first figure out how many rects to allocate
	CGSize imageSize = _texture.size;
	_tilesPerRow = (imageSize.width - _margin * 2 + _spacing) / (_tileSize.width + _spacing);
	_tilesPerColumn = (imageSize.height - _margin * 2 + _spacing) / (_tileSize.height + _spacing);
	_lastGid = _firstGid + (_tilesPerRow * _tilesPerColumn) - 1;
	if (_tilemap.highestGid < _lastGid)
	{
		_tilemap.highestGid = _lastGid;
	}

	// create the array
	NSUInteger tileTexturesCount = (_lastGid + 1) - _firstGid;
	_tileTextures = [NSMutableArray arrayWithCapacity:tileTexturesCount];

	// now create the rects and store them in buffer
	gid_t gid = _firstGid;
	while (gid <= _lastGid)
	{
		[_tileTextures addObject:[self createTextureForGid:gid++]];
	}
}

-(SKTexture*) createTextureForGid:(gid_t)gid
{
	CGRect rect;
	rect.size = _tileSize;
	gid = gid - _firstGid;
	rect.origin.x = (gid % _tilesPerRow) * (_tileSize.width + _spacing) + _margin;
	rect.origin.y = (gid / _tilesPerRow) * (_tileSize.height + _spacing) + _margin;
	return [SKTexture textureWithRect:rect inTexture:_texture];
}

-(SKTexture*) textureForGid:(gid_t)gid
{
	if (_alternateTileset)
	{
		gid_t alternateGid = (gid - _firstGid) + _alternateTileset.firstGid;
		return [_alternateTileset textureForGid:alternateGid];
	}

	gid_t tilesetGid = (gid & KTTilemapTileFlipMask);
	if (gid == 0 || tilesetGid < _firstGid || tilesetGid > _lastGid)
	{
		return nil;
	}

	tilesetGid -= _firstGid;
	NSAssert2(tilesetGid < _tileTextures.count, @"can't get texture rect for gid %u (index out of bounds) from tileset: %@", tilesetGid, self);
	return _tileTextures[tilesetGid];
}

-(KTTilemapProperties*) properties
{
	if (_alternateTileset)
	{
		return [_alternateTileset properties];
	}

	if (_properties == nil)
	{
		_properties = [[KTTilemapProperties alloc] init];
	}

	return _properties;
}

-(KTTilemapTileProperties*) tileProperties
{
	if (_alternateTileset)
	{
		return [_alternateTileset tileProperties];
	}

	if (_tileProperties == nil)
	{
		_tileProperties = [[KTTilemapTileProperties alloc] init];
	}

	return _tileProperties;
}

@dynamic alternateTileset;
-(KTTilemapTileset*) alternateTileset
{
	return _alternateTileset;
}

-(void) setAlternateTileset:(KTTilemapTileset*)alternateTileset
{
	_alternateTileset = alternateTileset;
}

@end

