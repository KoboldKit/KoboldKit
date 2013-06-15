//
// KTTilemap.m
// Kobold2D-Libraries
//
// Created by Steffen Itterheim on 13.10.12.
//
//



#import "KTTilemap.h"
#import "KTTilemapTileset.h"
#import "KTTilemapProperties.h"
#import "KTTilemapTileset.h"
#import "KTTilemapLayer.h"
#import "KTTilemapLayerTiles.h"
#import "KTTilemapObject.h"
#import "KTTMXReader.h"
#import "KTTMXWriter.h"
#import "KKMacros.h"
#import "KTIvarSetter.h"

#import "CGPointExtension.h"
#import "KoboldKit.h"

#pragma mark KTTilemap

@implementation KTTilemap

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

+(id) tilemapWithTMXFile:(NSString*)tmxFile
{
	return [[self alloc] initWithTMXFile:tmxFile];
}

-(id) initWithTMXFile:(NSString*)tmxFile
{
	self = [self init];
	if (self)
	{
		[self setDefaults];
		[self parseTMXFile:tmxFile];
		[self applyIpadScaleFactor];
	}

	return self;
}

+(id) tilemapWithOrientation:(KTTilemapOrientation)orientation mapSize:(CGSize)mapSize gridSize:(CGSize)gridSize
{
	return [[self alloc] initWithOrientation:orientation mapSize:mapSize gridSize:gridSize];
}

-(id) initWithOrientation:(KTTilemapOrientation)orientation mapSize:(CGSize)mapSize gridSize:(CGSize)gridSize
{
	self = [self init];
	if (self)
	{
		[self setDefaults];
		_orientation = orientation;
		_mapSize = mapSize;
		_gridSize = gridSize;
	}

	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ (orientation: %i, mapSize: %.0f,%.0f, gridSize: %.0f,%.0f, properties: %u, tileSets: %u, layers: %u)",
			[super description], _orientation, _mapSize.width, _mapSize.height, _gridSize.width, _gridSize.height,
			(unsigned int)_properties.count, (unsigned int)_tilesets.count, (unsigned int)_layers.count];
}

-(NSString*) debugDescription
{
	NSMutableString* str = [NSMutableString stringWithCapacity:4096];
	[str appendFormat:@"\n%@\nmap properties: %@", [self description], _properties];

	for (KTTilemapTileset* tileset in _tilesets)
	{
		[str appendFormat:@"\n%@", [tileset description]];
	}

	for (KTTilemapLayer* layer in _layers)
	{
		[str appendFormat:@"\n%@", [layer description]];
		if (layer.properties)
		{
			[str appendFormat:@"\nlayer properties: %@", layer.properties];
		}

		for (KTTilemapObject* object in layer.objects)
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
#if TARGET_OS_IPHONE
	if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) && _iPadScaleFactorApplied == NO)
	{
		_iPadScaleFactorApplied = YES; // avoid repeatedly scaling the map

		_gridSize.width *= _iPadScaleFactor;
		_gridSize.height *= _iPadScaleFactor;
		for (KTTilemapTileset* tileset in _tilesets)
		{
			tileset.tileSize = CGSizeMake(tileset.tileSize.width * _iPadScaleFactor, tileset.tileSize.height * _iPadScaleFactor);
			if (_scaleTilesetSpacingAndMargin)
			{
				tileset.spacing *= _iPadScaleFactor;
				tileset.margin *= _iPadScaleFactor;
			}
		}

		Class polyObjectClass = [KTTilemapPolyObject class];
		for (KTTilemapLayer* layer in _layers)
		{
			for (KTTilemapObject* object in layer.objects)
			{
				object.position = ccpMult(object.position, _iPadScaleFactor);
				object.size = CGSizeMake(object.size.width * _iPadScaleFactor, object.size.height * _iPadScaleFactor);

				if ([object isKindOfClass:polyObjectClass])
				{
					KTTilemapPolyObject* polyObject = (KTTilemapPolyObject*)object;
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
}

#pragma mark Apply Tiled Properties

-(void) applyTiledProperties
{
	// Tiled properties that match name and type of a class' ivar are set to the object's ivar
	// This allows users to configure KTTilemap* class properties from within Tiled (though there's always the risk of misusing this power)
	{
		KTIvarSetter* ivarSetter = [[KTIvarSetter alloc] initWithClass:[KTTilemap class]];
		[ivarSetter setIvarsFromDictionary:_properties.properties target:self];
	}
	{
		KTIvarSetter* ivarSetter = [[KTIvarSetter alloc] initWithClass:[KTTilemapTileset class]];
		for (KTTilemapTileset* tileset in _tilesets)
		{
			[ivarSetter setIvarsFromDictionary:tileset.properties.properties target:tileset];
		}
	}
	{
		KTIvarSetter* ivarSetter = [[KTIvarSetter alloc] initWithClass:[KTTilemapLayer class]];
		KTIvarSetter* ivarSetterObject = [[KTIvarSetter alloc] initWithClass:[KTTilemapObject class]];
		for (KTTilemapLayer* layer in _layers)
		{
			[ivarSetter setIvarsFromDictionary:layer.properties.properties target:layer];

			for (KTTilemapObject* object in layer.objects)
			{
				[ivarSetterObject setIvarsFromDictionary:object.properties.properties target:object];
			}
		}
	}
} /* applyTiledProperties */

#pragma mark Read/Write

-(NSString*) pathForTMXFile:(NSString*)tmxFile
{
	// default to assuming the file is in the bundle if it's not an absolute path
	if ([tmxFile isAbsolutePath] == NO)
	{
		return [KoboldKit pathForBundleFile:tmxFile];
	}
	
	return tmxFile;
}

-(void) parseTMXFile:(NSString*)tmxFile
{
	@autoreleasepool
	{
		KTTMXReader* parser = [[KTTMXReader alloc] init];
		[parser parseTMXFile:[self pathForTMXFile:tmxFile] tilemap:self];
		parser = nil;
	}

	[self applyTiledProperties];
}

-(void) writeToTMXFile:(NSString*)path
{
	@autoreleasepool
	{
		KTTMXWriter* writer = [[KTTMXWriter alloc] init];
		[writer writeTMXFile:path tilemap:self];
		writer = nil;
	}
}

#pragma mark Tiles & Tilesets

-(void) replaceTileset:(KTTilemapTileset*)originalTileset withTileset:(KTTilemapTileset*)otherTileset
{
	[originalTileset setAlternateTileset:otherTileset];
	self.forceDraw = YES;
}

-(void) restoreTileset:(KTTilemapTileset*)originalTileset
{
	[self replaceTileset:originalTileset withTileset:nil];
}

-(KTTilemapTileset*) tilesetForGid:(gid_t)gid
{
	KTTilemapTileset* foundTileset = nil;

	gid_t gidWithoutFlags = (gid & KTTilemapTileFlipMask);
	NSAssert2(_highestGid >= gidWithoutFlags,
			  @"Invalid gid: there's no tileset for gid %u - highest available gid is %u.\nNOTE: if this happens on a Retina iPad supply -ipadhd tilesets or set CCFileUtils iPad suffixes as shown in _Feature-Demo-Template_ -> TilemapWithBorderSceneViewController",
			  gidWithoutFlags, _highestGid);

	if (gidWithoutFlags > 0)
	{
		for (KTTilemapTileset* tileset in _tilesets)
		{
			if (tileset.firstGid > gidWithoutFlags)
			{
				break;
			}

			foundTileset = tileset;
		}
	}

	return foundTileset;
} /* tilesetForGid */

-(KTTilemapTileset*) tilesetForName:(NSString*)name
{
	for (KTTilemapTileset* tileset in _tilesets)
	{
		if ([tileset.name isEqualToString:name])
		{
			return tileset;
		}
	}

	return nil;
}

-(void) addTileset:(KTTilemapTileset*)tileset
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

-(void) addLayer:(KTTilemapLayer*)layer
{
	[_layers addObject:layer];
}

-(KTTilemapLayer*) layerByName:(NSString*)name
{
	for (KTTilemapLayer* layer in _layers)
	{
		if ([layer.name isEqualToString:name])
		{
			return layer;
		}
	}

	return nil;
}

#pragma mark Properties

-(KTTilemapProperties*) properties
{
	if (_properties == nil)
	{
		_properties = [[KTTilemapProperties alloc] init];
	}

	return _properties;
}

@end

