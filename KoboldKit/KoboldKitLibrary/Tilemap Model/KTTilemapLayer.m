//
// KTTilemapLayer.m
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 20.12.12.
//
//



#import "KTTilemapLayer.h"
#import "KTTilemap.h"
#import "KTTilemapTileset.h"
#import "KTTilemapLayerTiles.h"
#import "KTTilemapProperties.h"
#import "KTTilemapObject.h"

@implementation KTTilemapLayer

-(id) init
{
	self = [super init];
	if (self)
	{
		_parallaxFactor = CGPointMake(1.0f, 1.0f);
		_visible = YES;
		_opacity = 255;
	}

	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ (name: '%@', size: %.0f,%.0f, opacity: %i, visible: %i, isObjectLayer: %i, objects: %u, tiles: %@, properties: %u)",
			[super description], _name, _size.width, _size.height, _opacity, _visible, _isObjectLayer, (unsigned int)_objects.count, _tiles, (unsigned int)_properties.count];
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
} /* indexForTileCoord */

-(gid_t) tileGidAt:(CGPoint)tileCoord
{
	unsigned int index = [self indexForTileCoord:tileCoord];
	if (index >= _tileCount || _isObjectLayer)
	{
		return 0; // all illegal indices simply return 0 (the "empty" tile)
	}

	return _tiles.gid[index] & KTTilemapTileFlipMask;
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
		gid_t oldGidFlags = (_tiles.gid[index] & KTTilemapTileFlippedAll);
		_tiles.gid[index] = (gid | oldGidFlags);
		_tilemap.forceDraw = YES;
	}
}

-(void) setTileGidWithFlags:(gid_t)gidWithFlags tileCoord:(CGPoint)tileCoord
{
	unsigned int index = [self indexForTileCoord:tileCoord];
	if (index < _tileCount && _isObjectLayer == NO)
	{
		_tiles.gid[index] = gidWithFlags;
		_tilemap.forceDraw = YES;
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

-(KTTilemapProperties*) properties
{
	if (_properties == nil)
	{
		_properties = [[KTTilemapProperties alloc] init];
	}

	return _properties;
}

-(KTTilemapLayerTiles*) tiles
{
	if (_tiles == nil && _isObjectLayer == NO)
	{
		_tiles = [[KTTilemapLayerTiles alloc] init];
	}

	return _tiles;
}

#pragma mark Objects

-(void) addObject:(KTTilemapObject*)object
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

-(void) removeObject:(KTTilemapObject*)object
{
	if (_isObjectLayer)
	{
		[_objects removeObject:object];
	}
}

-(KTTilemapObject*) objectAtIndex:(NSUInteger)index
{
	if (_isObjectLayer && index < _objects.count)
	{
		return [_objects objectAtIndex:index];
	}

	return nil;
}

-(KTTilemapObject*) objectByName:(NSString*)name
{
	for (KTTilemapObject* object in _objects)
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

