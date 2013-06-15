//
// KTTMXWriter.m
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 02.02.13.
//
//


#import "KTTMXWriter.h"
#import "KTTilemap.h"
#import "KTTilemapProperties.h"
#import "KTTilemapTileProperties.h"
#import "KTTilemapTileset.h"
#import "KTTilemapLayerTiles.h"
#import "KTTilemapObject.h"
#import "KTTilemapLayer.h"
#import "KKMutableNumber.h"

#import <zlib.h>
#import "XMLWriter.h"
#import "KKSpriteKit.h"

// Base 64 encoding example from http://stackoverflow.com/a/6782480/201863

unsigned char encoding_table[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static int mod_table[] = {
	0, 2, 1
};

char* base64_encode(const unsigned char* data, size_t input_length, size_t* output_length)
{
	*output_length = ((input_length - 1) / 3) * 4 + 4;

	char* encoded_data = malloc(*output_length);
	if (encoded_data == NULL)
	{
		return NULL;
	}

	for (size_t i = 0, j = 0; i < input_length; )
	{
		uint32_t octet_a = i < input_length ? data[i++] : 0;
		uint32_t octet_b = i < input_length ? data[i++] : 0;
		uint32_t octet_c = i < input_length ? data[i++] : 0;
		uint32_t triple = (octet_a << 0x10) + (octet_b << 0x08) + octet_c;

		encoded_data[j++] = encoding_table[(triple >> 3 * 6) & 0x3F];
		encoded_data[j++] = encoding_table[(triple >> 2 * 6) & 0x3F];
		encoded_data[j++] = encoding_table[(triple >> 1 * 6) & 0x3F];
		encoded_data[j++] = encoding_table[(triple >> 0 * 6) & 0x3F];
	}

	for (int i = 0; i < mod_table[input_length % 3]; i++)
	{
		encoded_data[*output_length - 1 - i] = '=';
	}

	return encoded_data;
} /* base64_encode */

NSString* stringFromBool(BOOL b)
{
	if (b)
	{
		return @"YES";
	}

	return @"NO";
}

NSString* stringFromFloat(float f)
{
	return [NSString stringWithFormat:@"%f", f];
}

NSString* intStringFromFloat(float f)
{
	return [NSString stringWithFormat:@"%.0f", f];
}

NSString* stringFromInt(int i)
{
	return [NSString stringWithFormat:@"%d", i];
}

NSString* stringFromUnsignedInt(unsigned int u)
{
	return [NSString stringWithFormat:@"%u", u];
}

@implementation KTTMXWriter

-(void) writeTMXFile:(NSString*)file tilemap:(KTTilemap*)tilemap
{
	_tilemap = tilemap;

	_xmlWriter = [[XMLWriter alloc] init];
	[_xmlWriter writeStartDocumentWithEncoding:@"UTF-8" version:@"1.0"];
	[_xmlWriter write:@"\n<!DOCTYPE map SYSTEM \"http://mapeditor.org/dtd/1.0/map.dtd\">"];

	[self writeTilemap:tilemap];
	for (KTTilemapTileset* tileset in tilemap.tilesets)
	{
		[self writeTileset:tileset];
	}

	for (KTTilemapLayer* layer in tilemap.layers)
	{
		[self writeLayer:layer];
	}

	[_xmlWriter writeEndDocument];

	// LOG_EXPR([_xmlWriter toString]);
} /* writeTMXFile */

-(void) writeTilemap:(KTTilemap*)tilemap
{
	[_xmlWriter writeStartElement:@"map"];
	[_xmlWriter writeAttribute:@"version" value:@"1.0"];

	switch (tilemap.orientation)
	{
		case KTTilemapOrientationOrthogonal:
			[_xmlWriter writeAttribute:@"orientation" value:@"orthogonal"];
			break;

		case KTTilemapOrientationIsometric:
			[_xmlWriter writeAttribute:@"orientation" value:@"isometric"];
			break;

		case KTTilemapOrientationStaggeredIsometric:
			[_xmlWriter writeAttribute:@"orientation" value:@"staggered"];
			break;

		case KTTilemapOrientationHexagonal:
			[_xmlWriter writeAttribute:@"orientation" value:@"hexagonal"];
			break;
	} /* switch */

	[_xmlWriter writeAttribute:@"width" value:intStringFromFloat(tilemap.mapSize.width)];
	[_xmlWriter writeAttribute:@"height" value:intStringFromFloat(tilemap.mapSize.height)];
	[_xmlWriter writeAttribute:@"tilewidth" value:intStringFromFloat(tilemap.gridSize.width)];
	[_xmlWriter writeAttribute:@"tileheight" value:intStringFromFloat(tilemap.gridSize.height)];
	[_xmlWriter writeAttribute:@"backgroundcolor" value:tilemap.backgroundColor];

	[self writeProperties:tilemap.properties];

	[_xmlWriter writeEndElement];
} /* writeTilemap */

-(void) writeTileset:(KTTilemapTileset*)tileset
{
	[_xmlWriter writeStartElement:@"tileset"];
	[_xmlWriter writeAttribute:@"firstgid" value:stringFromInt(tileset.firstGid)];
	[_xmlWriter writeAttribute:@"name" value:tileset.name];
	[_xmlWriter writeAttribute:@"tilewidth" value:stringFromInt(tileset.tileSize.width)];
	[_xmlWriter writeAttribute:@"tileheight" value:stringFromInt(tileset.tileSize.height)];
	[_xmlWriter writeAttribute:@"spacing" value:stringFromInt(tileset.spacing)];
	[_xmlWriter writeAttribute:@"margin" value:stringFromInt(tileset.margin)];

	if (CGPointEqualToPoint(tileset.drawOffset, CGPointZero) == NO)
	{
		[_xmlWriter writeStartElement:@"tileoffset"];
		[_xmlWriter writeAttribute:@"x" value:intStringFromFloat(tileset.drawOffset.x)];
		[_xmlWriter writeAttribute:@"y" value:intStringFromFloat(tileset.drawOffset.y)];
		[_xmlWriter writeEndElement];
	}

	if (tileset.imageFile)
	{
		[_xmlWriter writeStartElement:@"image"];
		[_xmlWriter writeAttribute:@"source" value:tileset.imageFile];
		[_xmlWriter writeAttribute:@"width" value:intStringFromFloat(tileset.texture.size.width)];
		[_xmlWriter writeAttribute:@"height" value:intStringFromFloat(tileset.texture.size.height)];
		[_xmlWriter writeEndElement];
	}

	[tileset.tileProperties.properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop)
	{
		KTTilemapProperties* tileProperties = (KTTilemapProperties*)obj;
		NSAssert1([tileProperties isKindOfClass:[KTTilemapProperties class]], @"KTTMXWriter: can't write tile properties (%@), not a KTTilemapProperties object!", obj);

		[_xmlWriter writeStartElement:@"tile"];
		gid_t localGid = [(NSNumber*)key unsignedIntValue] - tileset.firstGid;
		[_xmlWriter writeAttribute:@"id" value:stringFromUnsignedInt(localGid)];
		[self writeProperties:tileProperties];
		[_xmlWriter writeEndElement];
	}];

	[_xmlWriter writeEndElement];
} /* writeTileset */

-(void) writeLayer:(KTTilemapLayer*)layer
{
	if (layer.isTileLayer)
	{
		[_xmlWriter writeStartElement:@"layer"];
	}
	else
	{
		[_xmlWriter writeStartElement:@"objectgroup"];
	}

	[_xmlWriter writeAttribute:@"name" value:layer.name];
	[_xmlWriter writeAttribute:@"width" value:intStringFromFloat(layer.tilemap.mapSize.width)];
	[_xmlWriter writeAttribute:@"height" value:intStringFromFloat(layer.tilemap.mapSize.height)];
	[_xmlWriter writeAttribute:@"opacity" value:stringFromFloat(layer.opacity)];
	[_xmlWriter writeAttribute:@"visible" value:stringFromInt(layer.visible)];

	[self writeProperties:layer.properties];

	if (layer.isTileLayer)
	{
		[_xmlWriter writeStartElement:@"data"];
		[_xmlWriter writeAttribute:@"encoding" value:@"base64"];
		[_xmlWriter writeAttribute:@"compression" value:@"zlib"];
		[_xmlWriter writeCloseStartElement]; // must close data element before writing the "raw" base64 string
		[_xmlWriter write:[self encodedDataStringFromTileLayer:layer]];
		[_xmlWriter writeEndElement];
	}
	else
	{
		for (KTTilemapObject* object in layer.objects)
		{
			[self writeObject:object];
		}
	}

	[_xmlWriter writeEndElement];
} /* writeLayer */

// returns a base64, zlib compressed tile data string
-(NSString*) encodedDataStringFromTileLayer:(KTTilemapLayer*)layer
{
	size_t bufferSize = compressBound(layer.tiles.gidSize);
	unsigned char* buffer = malloc(bufferSize);
	NSAssert2(buffer, @"KTTMXWriter: failed to allocate %u bytes for tile layer (%@) data", (unsigned int)bufferSize, layer);

	int result = compress(buffer, &bufferSize, (unsigned char*)layer.tiles.gid, layer.tiles.gidSize);
	if (result != Z_OK)
	{
		NSString* error = @"unknown error";
		switch (result)
		{
			case Z_MEM_ERROR:
				error = @"not enough memory";
				break;

			case Z_BUF_ERROR:
				error = @"output buffer too small";
				break;
		}

		[NSException raise:@"KTTMXWriter: couldn't compress layer tiles" format:@"compressing layer (%@) failed: %@", layer, error];
	}

	size_t encodedLength = 0;
	NSString* dataString = [[NSString alloc] initWithBytesNoCopy:base64_encode(buffer, bufferSize, &encodedLength)
														  length:encodedLength
														encoding:NSUTF8StringEncoding
													freeWhenDone:YES];
	free(buffer);

	NSAssert(dataString, @"KTTMXWriter: failed to create base64 encoded NSString");
	return dataString;
} /* encodedDataStringFromTileLayer */

-(void) writeObject:(KTTilemapObject*)object
{
	[_xmlWriter writeStartElement:@"object"];
	[_xmlWriter writeAttribute:@"name" value:object.name];
	[_xmlWriter writeAttribute:@"type" value:object.userType];
	[_xmlWriter writeAttribute:@"x" value:intStringFromFloat(object.position.x)];
	float yPos = (_tilemap.mapSize.height * _tilemap.gridSize.height) - object.position.y;
	if (object.objectType == KTTilemapObjectTypeRectangle)
	{
		yPos -= object.size.height;
	}

	[_xmlWriter writeAttribute:@"y" value:intStringFromFloat(yPos)];

	if (CGSizeEqualToSize(object.size, CGSizeZero) == NO)
	{
		[_xmlWriter writeAttribute:@"width" value:intStringFromFloat(object.size.width)];
		[_xmlWriter writeAttribute:@"height" value:intStringFromFloat(object.size.height)];
	}

	// [_xmlWriter writeAttribute:@"visible" value:stringFromInt(object.visible)];

	[self writeProperties:object.properties];

	// write specific subclasses
	if (object.objectType == KTTilemapObjectTypePolygon || object.objectType == KTTilemapObjectTypePolyLine)
	{
		[_xmlWriter writeStartElement:(object.objectType == KTTilemapObjectTypePolygon ? @"polygon" : @"polyline")];
		[self writePolyObjectPoints:(KTTilemapPolyObject*)object];
		[_xmlWriter writeEndElement];
	}

	[_xmlWriter writeEndElement];
} /* writeObject */

-(void) writePolyObjectPoints:(KTTilemapPolyObject*)polyObject
{
	NSMutableString* pointsString = [NSMutableString stringWithCapacity:80];

	for (NSUInteger i = 0; i < polyObject.numberOfPoints; i++)
	{
		if (i > 0)
		{
			[pointsString appendString:@" "];
		}

		CGPoint point = polyObject.points[i];
		[pointsString appendFormat:@"%i,%i", (int)point.x, -(int)point.y];
	}

	[_xmlWriter writeAttribute:@"points" value:pointsString];
} /* writePolyObjectPoints */

#pragma mark Properties Writer

static Class stringClass = nil;
static Class intNumberClass = nil;
static Class floatNumberClass = nil;
static Class boolNumberClass = nil;

-(void) writeProperties:(KTTilemapProperties*)tilemapProperties
{
	if (stringClass == nil)
	{
		stringClass = [NSString class];
		intNumberClass = [KKInt32Number class];
		floatNumberClass = [KKFloatNumber class];
		boolNumberClass = [KKBoolNumber class];
	}

	if (tilemapProperties.count > 0)
	{
		[_xmlWriter writeStartElement:@"properties"];

		[tilemapProperties.properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop)
		{
			[_xmlWriter writeStartElement:@"property"];
			[_xmlWriter writeAttribute:@"name" value:key];

			if ([obj isKindOfClass:stringClass])
			{
				[_xmlWriter writeAttribute:@"value" value:obj];
			}
			else if ([obj isKindOfClass:intNumberClass])
			{
				[_xmlWriter writeAttribute:@"value" value:stringFromInt([(KKMutableNumber*)obj intValue])];
			}
			else if ([obj isKindOfClass:floatNumberClass])
			{
				[_xmlWriter writeAttribute:@"value" value:stringFromFloat([(KKMutableNumber*)obj floatValue])];
			}
			else if ([obj isKindOfClass:boolNumberClass])
			{
				[_xmlWriter writeAttribute:@"value" value:stringFromBool([(KKMutableNumber*)obj boolValue])];
			}
			else
			{
				[NSException raise:@"KTTMXWriter: unsupported property value type" format:@"could not write property value (%@) for key (%@)", obj, key];
			}

			[_xmlWriter writeEndElement];
		}];

		[_xmlWriter writeEndElement];
	}
} /* writeProperties */

@end

