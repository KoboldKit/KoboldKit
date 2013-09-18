/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTilemap.h"
#import "KKClassVarSetter.h"

#pragma mark KTTilemap

@implementation KKTilemap

#pragma mark Init

-(void) setDefaults
{
	_iPadScaleFactor = 1.0f;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		_tilesets = [NSMutableArray array];
		_layers = [NSMutableArray array];
	}

	return self;
}

+(id) tilemapWithContentsOfFile:(NSString*)tmxFile
{
	return [[self alloc] initWithTMXFile:tmxFile];
}

-(id) initWithTMXFile:(NSString*)tmxFile
{
	self = [self init];
	if (self)
	{
		[self setDefaults];
		[self loadTMXFile:tmxFile];
		[self applyIpadScaleFactor];
	}

	return self;
}

+(id) tilemapWithOrientation:(KKTilemapOrientation)orientation mapSize:(CGSize)mapSize gridSize:(CGSize)gridSize
{
	return [[self alloc] initWithOrientation:orientation mapSize:mapSize gridSize:gridSize];
}

-(id) initWithOrientation:(KKTilemapOrientation)orientation mapSize:(CGSize)mapSize gridSize:(CGSize)gridSize
{
	self = [self init];
	if (self)
	{
		[self setDefaults];
		_orientation = orientation;
		_size = mapSize;
		_gridSize = gridSize;
	}

	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ (orientation: %i, size: %.0f,%.0f, gridSize: %.0f,%.0f, properties: %u, tileSets: %u, layers: %u)",
			[super description], _orientation, _size.width, _size.height, _gridSize.width, _gridSize.height,
			(unsigned int)_properties.count, (unsigned int)_tilesets.count, (unsigned int)_layers.count];
}

-(NSString*) debugDescription
{
	NSMutableString* str = [NSMutableString stringWithCapacity:4096];
	[str appendFormat:@"\n%@\nmap properties: %@", [self description], _properties];

	for (KKTilemapTileset* tileset in _tilesets)
	{
		[str appendFormat:@"\n%@", [tileset description]];
	}

	for (KKTilemapLayer* layer in _layers)
	{
		[str appendFormat:@"\n%@", [layer description]];
		if (layer.properties)
		{
			[str appendFormat:@"\nlayer properties: %@", layer.properties];
		}

		for (KKTilemapObject* object in layer.objects)
		{
			[str appendFormat:@"\n\t%@", [object description]];
			if (object.properties)
			{
				[str appendFormat:@"\n\tobject properties: %@", object.properties];
			}
		}
	}

	return str;
} /* debugDescription */

-(void) applyIpadScaleFactor
{
	/*
#if TARGET_OS_IPHONE
	if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) && _iPadScaleFactorApplied == NO)
	{
		_iPadScaleFactorApplied = YES; // avoid repeatedly scaling the map

		_gridSize.width *= _iPadScaleFactor;
		_gridSize.height *= _iPadScaleFactor;
		for (KKTilemapTileset* tileset in _tilesets)
		{
			tileset.tileSize = CGSizeMake(tileset.tileSize.width * _iPadScaleFactor, tileset.tileSize.height * _iPadScaleFactor);
			if (_scaleTilesetSpacingAndMargin)
			{
				tileset.spacing *= _iPadScaleFactor;
				tileset.margin *= _iPadScaleFactor;
			}
		}

		Class polyObjectClass = [KKTilemapPolyObject class];
		for (KKTilemapLayer* layer in _layers)
		{
			for (KKTilemapObject* object in layer.objects)
			{
				object.position = ccpMult(object.position, _iPadScaleFactor);
				object.size = CGSizeMake(object.size.width * _iPadScaleFactor, object.size.height * _iPadScaleFactor);

				if ([object isKindOfClass:polyObjectClass])
				{
					KKTilemapPolyObject* polyObject = (KKTilemapPolyObject*)object;
					for (unsigned int i = 0; i < polyObject.numberOfPoints; i++)
					{
						polyObject.points[i] = ccpMult(polyObject.points[i], _iPadScaleFactor);
					}

					[polyObject updateBoundingBox];
				}
			}
		}
	}
#endif
	*/
}

#pragma mark Apply Tiled Properties

-(void) applyTiledProperties
{
	// Tiled properties that match name and type of a class' ivar are set to the object's ivar
	// This allows users to configure KTTilemap* class properties from within Tiled (though there's always the risk of misusing this power)
	{
		KKClassVarSetter* ivarSetter = [[KKClassVarSetter alloc] initWithClass:[KKTilemap class]];
		[ivarSetter setIvarsWithDictionary:_properties.properties target:self];
		//[ivarSetter setPropertiesWithDictionary:_properties.properties target:self];
	}
	{
		KKClassVarSetter* ivarSetter = [[KKClassVarSetter alloc] initWithClass:[KKTilemapTileset class]];
		for (KKTilemapTileset* tileset in _tilesets)
		{
			[ivarSetter setIvarsWithDictionary:tileset.properties.properties target:tileset];
			//[ivarSetter setPropertiesWithDictionary:tileset.properties.properties target:tileset];
		}
	}
	{
		KKClassVarSetter* ivarSetter = [[KKClassVarSetter alloc] initWithClass:[KKTilemapLayer class]];
		KKClassVarSetter* ivarSetterObject = [[KKClassVarSetter alloc] initWithClass:[KKTilemapObject class]];
		for (KKTilemapLayer* layer in _layers)
		{
			[ivarSetter setIvarsWithDictionary:layer.properties.properties target:layer];
			//[ivarSetter setPropertiesWithDictionary:layer.properties.properties target:layer];

			for (KKTilemapObject* object in layer.objects)
			{
				[ivarSetterObject setIvarsWithDictionary:object.properties.properties target:object];
				//[ivarSetterObject setPropertiesWithDictionary:object.properties.properties target:object];
			}
		}
	}
} /* applyTiledProperties */

#pragma mark Read/Write

-(NSString*) pathForTMXFile:(NSString*)tmxFile
{
	if ([tmxFile isAbsolutePath] == NO)
	{
		return [NSBundle pathForFile:tmxFile];
	}
	
	return tmxFile;
}

-(void) loadTMXFile:(NSString*)tmxFile
{
	@autoreleasepool
	{
		KKTMXReader* reader = [[KKTMXReader alloc] init];
		NSString* path = [self pathForTMXFile:tmxFile];
		NSAssert1(path, @"TMX file '%@' not found!", tmxFile);
		
		[reader loadTMXFile:path tilemap:self];
		reader = nil;
	}

	[self applyTiledProperties];
}

-(void) writeToFile:(NSString*)path
{
	@autoreleasepool
	{
		KKTMXWriter* writer = [[KKTMXWriter alloc] init];
		[writer writeTMXFile:path tilemap:self];
		writer = nil;
	}
}

#pragma mark Tiles & Tilesets

-(void) replaceTileset:(KKTilemapTileset*)originalTileset withTileset:(KKTilemapTileset*)otherTileset
{
	[originalTileset setAlternateTileset:otherTileset];
	self.modified = YES;
}

-(void) restoreTileset:(KKTilemapTileset*)originalTileset
{
	[self replaceTileset:originalTileset withTileset:nil];
}

-(KKTilemapTileset*) tilesetForGid:(gid_t)gid
{
	gid_t gidWithoutFlags = (gid & KKTilemapTileFlipMask);
	return [self tilesetForGidWithoutFlags:gidWithoutFlags];
}

-(KKTilemapTileset*) tilesetForGidWithoutFlags:(gid_t)gidWithoutFlags
{
	NSAssert1((gidWithoutFlags & KKTilemapTileFlipMask) == gidWithoutFlags, @"gid %u has flags set! Mask out flags or use tilesetForGid: instead.", gidWithoutFlags);
	NSAssert2(_highestGid >= gidWithoutFlags,
			  @"Invalid gid: there's no tileset for gid %u - highest available gid is %u.",
			  gidWithoutFlags, _highestGid);
	
	KKTilemapTileset* foundTileset = nil;
	
	if (gidWithoutFlags != 0)
	{
		for (KKTilemapTileset* tileset in _tilesets)
		{
			if (tileset.firstGid > gidWithoutFlags)
			{
				break;
			}
			
			foundTileset = tileset;
		}
	}
	
	return foundTileset;
}

-(KKTilemapTileset*) tilesetNamed:(NSString*)name
{
	for (KKTilemapTileset* tileset in _tilesets)
	{
		if ([tileset.name isEqualToString:name])
		{
			return tileset;
		}
	}

	return nil;
}

-(void) addTileset:(KKTilemapTileset*)tileset
{
	tileset.tilemap = self;
	[_tilesets addObject:tileset];
	[self updateLargestTileSizeWithTileSize:tileset.tileSize];
}

-(void) updateLargestTileSizeWithTileSize:(CGSize)tileSize
{
	if (tileSize.width > _largestTileSize.width)
	{
		_largestTileSize.width = tileSize.width;
	}

	if (tileSize.height > _largestTileSize.height)
	{
		_largestTileSize.height = tileSize.height;
	}
}

#pragma mark Layers

-(void) addLayer:(KKTilemapLayer*)layer
{
	[_layers addObject:layer];
}

-(KKTilemapLayer*) layerNamed:(NSString*)name
{
	for (KKTilemapLayer* layer in _layers)
	{
		if ([layer.name isEqualToString:name])
		{
			return layer;
		}
	}

	return nil;
}

#pragma mark Properties

-(KKTilemapProperties*) properties
{
	if (_properties == nil)
	{
		_properties = [[KKTilemapProperties alloc] init];
	}

	return _properties;
}

@end

