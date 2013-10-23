/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKFramework.h"
#import "KKTilemapTileset.h"
#import "KKTilemap.h"
#import "KKTilemapProperties.h"
#import "KKTilemapTileProperties.h"

@implementation KKTilemapTileset

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

@dynamic texture;
-(void) setTexture:(SKTexture *)texture
{
	_texture = texture;
	[self createTileTextures];
}

-(SKTexture*) texture
{
	if (_alternateTileset)
	{
		return _alternateTileset.texture;
	}

	if (_texture == nil)
	{
DEVELOPER_TODO("tilemap pvr texture load")
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
			_texture = [KKTexture textureWithImageNamed:[NSBundle pathForFile:_imageFile]];
			_texture.filteringMode = SKTextureFilteringNearest;
		}

		NSAssert(_texture, @"could not find (or otherwise load) image file: '%@'", _imageFile);
		[self createTileTextures];
	}

	return _texture;
}

-(void) createTileTextures
{
	// first figure out how many rects to allocate
	CGSize textureSize = _texture.size;
	CGSize pixelSize = textureSize;
	if ([_imageFile containsString:@"@2x"])
	{
		pixelSize.width *= 2.0;
		pixelSize.height *= 2.0;
	}
	
	_tilesPerRow = (pixelSize.width - _margin * 2 + _spacing) / (_tileSize.width + _spacing);
	_tilesPerColumn = (pixelSize.height - _margin * 2 + _spacing) / (_tileSize.height + _spacing);
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
		[_tileTextures addObject:[self createTextureForGid:gid++ textureSize:pixelSize]];
	}
}

-(SKTexture*) createTextureForGid:(gid_t)gid textureSize:(CGSize)textureSize
{
	gid = gid - _firstGid;

	CGFloat x = (gid % _tilesPerRow) * (_tileSize.width + _spacing) + _margin;
	CGFloat y = (textureSize.height - _tileSize.height) - ((gid / _tilesPerRow) * (_tileSize.height + _spacing) + _margin);

	// convert to original texture's units
	CGRect rect = CGRectMake(x / textureSize.width, y / textureSize.height, _tileSize.width / textureSize.width, _tileSize.height / textureSize.height);
	
	SKTexture* tileTexture = [SKTexture textureWithRect:rect inTexture:_texture];
	tileTexture.filteringMode = SKTextureFilteringNearest;
	return tileTexture;
}

-(SKTexture*) textureForGid:(gid_t)gid
{
	gid_t gidWithoutFlags = (gid & KKTilemapTileFlipMask);
	return [self textureForGidWithoutFlags:gidWithoutFlags];
}

-(SKTexture*) textureForGidWithoutFlags:(gid_t)gidWithoutFlags
{
	NSAssert1((gidWithoutFlags & KKTilemapTileFlipMask) == gidWithoutFlags, @"gid %u has flags set! Mask out flags or use textureForGid: instead.", gidWithoutFlags);
	
	if (_alternateTileset)
	{
		gid_t alternateGid = (gidWithoutFlags - _firstGid) + _alternateTileset.firstGid;
		return [_alternateTileset textureForGid:alternateGid];
	}
	
	if (gidWithoutFlags == 0 || gidWithoutFlags < _firstGid || gidWithoutFlags > _lastGid)
	{
		return nil;
	}
	
	gidWithoutFlags -= _firstGid;
	NSAssert2(gidWithoutFlags < _tileTextures.count, @"can't get texture rect for gid %u (index out of bounds) from tileset: %@", gidWithoutFlags, self);
	return _tileTextures[gidWithoutFlags];
}

-(KKTilemapProperties*) properties
{
	if (_alternateTileset)
	{
		return [_alternateTileset properties];
	}

	if (_properties == nil)
	{
		_properties = [KKTilemapProperties new];
	}

	return _properties;
}

-(KKTilemapTileProperties*) tileProperties
{
	if (_alternateTileset)
	{
		return [_alternateTileset tileProperties];
	}

	if (_tileProperties == nil)
	{
		_tileProperties = [KKTilemapTileProperties new];
	}

	return _tileProperties;
}

@dynamic alternateTileset;
-(KKTilemapTileset*) alternateTileset
{
	return _alternateTileset;
}

-(void) setAlternateTileset:(KKTilemapTileset*)alternateTileset
{
	_alternateTileset = alternateTileset;
}

@end

