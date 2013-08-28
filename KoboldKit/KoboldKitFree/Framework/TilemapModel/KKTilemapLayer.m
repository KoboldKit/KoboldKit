/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTilemapLayer.h"
#import "KKTilemap.h"
#import "KKTilemapTileset.h"
#import "KKTilemapLayerTiles.h"
#import "KKTilemapProperties.h"
#import "KKTilemapObject.h"
#import "KKTilemapLayerContourTracer.h"
#import "KKPointArray.h"

@implementation KKTilemapLayer

-(id) init
{
	self = [super init];
	if (self)
	{
		_parallaxFactor = CGPointMake(1.0f, 1.0f);
		_hidden = NO;
		_alpha = 1.0f;
	}

	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ (name: '%@', size: %.0f,%.0f, opacity: %f, visible: %i, isObjectLayer: %i, objects: %u, tiles: %@, properties: %u)",
			[super description], _name, _size.width, _size.height, _alpha, _hidden, _isObjectLayer, (unsigned int)_objects.count, _tiles, (unsigned int)_properties.count];
}

#pragma mark Gid Setters/Getters

-(unsigned int) indexForTileCoord:(CGPoint)tileCoord
{
	if (_endlessScrollingHorizontal)
	{
		// adjust the tile coord to be within bounds of the map when endless scrolling is enabled
		tileCoord.x = (int)tileCoord.x % (int)_size.width;

		// ensure positive coords
		if (tileCoord.x < 0.0f)
		{
			tileCoord.x += _size.width;
		}
	}

	if (_endlessScrollingVertical)
	{
		// adjust the tile coord to be within bounds of the map when endless scrolling is enabled
		tileCoord.y = (int)tileCoord.y % (int)_size.height;

		// ensure positive coords
		if (tileCoord.y < 0.0f)
		{
			tileCoord.y += _size.height;
		}
	}

	return tileCoord.x + tileCoord.y * _size.width;
}

-(gid_t) tileGidAt:(CGPoint)tileCoord
{
	unsigned int index = [self indexForTileCoord:tileCoord];
	if (index >= _tileCount || _isObjectLayer)
	{
		return 0; // all illegal indices simply return 0 (the "empty" tile)
	}

	return _tiles.gid[index] & KKTilemapTileFlipMask;
}

-(gid_t) tileGidWithFlagsAt:(CGPoint)tileCoord
{
	unsigned int index = [self indexForTileCoord:tileCoord];
	if (index >= _tileCount || _isObjectLayer)
	{
		return 0; // all illegal indices simply return 0 (the "empty" tile)
	}

	return _tiles.gid[index];
}

-(void) setTileGid:(gid_t)gid tileCoord:(CGPoint)tileCoord
{
	unsigned int index = [self indexForTileCoord:tileCoord];
	if (index < _tileCount && _isObjectLayer == NO)
	{
		gid_t oldGidFlags = (_tiles.gid[index] & KKTilemapTileFlippedAll);
		_tiles.gid[index] = (gid | oldGidFlags);
		_tilemap.modified = YES;
	}
}

-(void) setTileGidWithFlags:(gid_t)gidWithFlags tileCoord:(CGPoint)tileCoord
{
	unsigned int index = [self indexForTileCoord:tileCoord];
	if (index < _tileCount && _isObjectLayer == NO)
	{
		_tiles.gid[index] = gidWithFlags;
		_tilemap.modified = YES;
	}
}

-(void) clearTileAt:(CGPoint)tileCoord
{
	[self setTileGidWithFlags:0 tileCoord:tileCoord];
}

@dynamic isTileLayer;
-(BOOL) isTileLayer
{
	return !_isObjectLayer;
}

-(void) setIsTileLayer:(BOOL)isTileLayer
{
	_isObjectLayer = !isTileLayer;
}

-(KKTilemapProperties*) properties
{
	if (_properties == nil)
	{
		_properties = [[KKTilemapProperties alloc] init];
	}

	return _properties;
}

-(KKTilemapLayerTiles*) tiles
{
	if (_tiles == nil && _isObjectLayer == NO)
	{
		_tiles = [[KKTilemapLayerTiles alloc] init];
	}

	return _tiles;
}

#pragma mark Collisions

-(NSArray*) contourPathsFromLayer:(KKTilemapLayer*)layer
{
	if (self.isObjectLayer)
	{
		return nil;
	}
	
	KKTilemapLayerContourTracer* contour = [KKTilemapLayerContourTracer contourMapFromTileLayer:self];
	return contour.contourSegments;
}

-(NSArray*) contourPathsWithBlockingGids:(KKIntegerArray*)blockingGids
{
	if (self.isObjectLayer)
	{
		return nil;
	}
	
	KKTilemapLayerContourTracer* contour = [KKTilemapLayerContourTracer contourMapFromTileLayer:self blockingGids:blockingGids];
	return contour.contourSegments;
}

-(NSArray*) pathsFromObjects
{
	if (_objects.count == 0)
	{
		return nil;
	}
	
	NSMutableArray* paths = [NSMutableArray arrayWithCapacity:_objects.count];
	for (KKTilemapObject* object in _objects)
	{
		[paths addObject:[object path]];
	}
	return paths;
}

#pragma mark Objects

-(void) addObject:(KKTilemapObject*)object
{
	if (_isObjectLayer)
	{
		if (_objects == nil)
		{
			_objects = [NSMutableArray arrayWithCapacity:20];
		}

		[_objects addObject:object];
	}
}

-(void) removeObject:(KKTilemapObject*)object
{
	if (_isObjectLayer)
	{
		[_objects removeObject:object];
	}
}

-(KKTilemapObject*) objectAtIndex:(NSUInteger)index
{
	if (_isObjectLayer && index < _objects.count)
	{
		return [_objects objectAtIndex:index];
	}

	return nil;
}

-(KKTilemapObject*) objectNamed:(NSString*)name
{
	for (KKTilemapObject* object in _objects)
	{
		if ([object.name isEqualToString:name])
		{
			return object;
		}
	}

	return nil;
}

#pragma mark Parallax & Endless

-(void) setParallaxFactor:(CGPoint)parallaxFactor
{
	if (parallaxFactor.x > 1.0f || parallaxFactor.x < 1.0f || parallaxFactor.y > 1.0f || parallaxFactor.y < 1.0f)
	{
		_endlessScrollingHorizontal = YES;
		_endlessScrollingVertical = YES;
	}

	_parallaxFactor = parallaxFactor;
}

@dynamic endlessScrolling;
-(void) setEndlessScrolling:(BOOL)endlessScrolling
{
	_endlessScrollingHorizontal = endlessScrolling;
	_endlessScrollingVertical = endlessScrolling;
}

-(BOOL) endlessScrolling
{
	return _endlessScrollingHorizontal || _endlessScrollingVertical;
}

@end

