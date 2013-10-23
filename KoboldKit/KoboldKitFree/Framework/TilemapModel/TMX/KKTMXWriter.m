/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTMXWriter.h"
#import "KKTilemap.h"
#import "KKTilemapProperties.h"
#import "KKTilemapTileProperties.h"
#import "KKTilemapTileset.h"
#import "KKTilemapLayerTiles.h"
#import "KKTilemapObject.h"
#import "KKTilemapLayer.h"
#import "KKMutableNumber.h"
#import "KKMacros.h"
#import "KKFramework.h"

#import <zlib.h>

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

@implementation KKTMXWriter

-(void) writeTMXFile:(NSString*)file tilemap:(KKTilemap*)tilemap
{
	_tilemap = tilemap;

	_xmlWriter = [XMLWriter new];
	[_xmlWriter writeStartDocumentWithEncoding:@"UTF-8" version:@"1.0"];
	[_xmlWriter write:@"\n<!DOCTYPE map SYSTEM \"http://mapeditor.org/dtd/1.0/map.dtd\">"];

	[self writeTilemap:tilemap];
	for (KKTilemapTileset* tileset in tilemap.tilesets)
	{
		[self writeTileset:tileset];
	}

	for (KKTilemapLayer* layer in tilemap.layers)
	{
		[self writeLayer:layer];
	}

	[_xmlWriter writeEndDocument];

	// LOG_EXPR([_xmlWriter toString]);
} /* writeTMXFile */

-(void) writeTilemap:(KKTilemap*)tilemap
{
	[_xmlWriter writeStartElement:@"map"];
	[_xmlWriter writeAttribute:@"version" value:@"1.0"];

	switch (tilemap.orientation)
	{
		case KKTilemapOrientationOrthogonal:
			[_xmlWriter writeAttribute:@"orientation" value:@"orthogonal"];
			break;

		case KKTilemapOrientationIsometric:
			[_xmlWriter writeAttribute:@"orientation" value:@"isometric"];
			break;

		case KKTilemapOrientationStaggeredIsometric:
			[_xmlWriter writeAttribute:@"orientation" value:@"staggered"];
			break;

		case KKTilemapOrientationHexagonal:
			[_xmlWriter writeAttribute:@"orientation" value:@"hexagonal"];
			break;
	} /* switch */

	[_xmlWriter writeAttribute:@"width" value:intStringFromFloat(tilemap.size.width)];
	[_xmlWriter writeAttribute:@"height" value:intStringFromFloat(tilemap.size.height)];
	[_xmlWriter writeAttribute:@"tilewidth" value:intStringFromFloat(tilemap.gridSize.width)];
	[_xmlWriter writeAttribute:@"tileheight" value:intStringFromFloat(tilemap.gridSize.height)];
	
	if (tilemap.backgroundColor)
	{
		const CGFloat* components = CGColorGetComponents(tilemap.backgroundColor.CGColor);
		NSString* colorString = [NSString stringWithFormat:@"#%02x%02x%02x",
								 (int)(0xFF * components[0]),
								 (int)(0xFF * components[1]),
								 (int)(0xFF * components[2])];
		[_xmlWriter writeAttribute:@"backgroundcolor" value:colorString];
	}

	[self writeProperties:tilemap.properties];

	[_xmlWriter writeEndElement];
} /* writeTilemap */

-(void) writeTileset:(KKTilemapTileset*)tileset
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
		KKTilemapProperties* tileProperties = (KKTilemapProperties*)obj;
		NSAssert1([tileProperties isKindOfClass:[KKTilemapProperties class]], @"KTTMXWriter: can't write tile properties (%@), not a KTTilemapProperties object!", obj);

		[_xmlWriter writeStartElement:@"tile"];
		gid_t localGid = [(NSNumber*)key unsignedIntValue] - tileset.firstGid;
		[_xmlWriter writeAttribute:@"id" value:stringFromUnsignedInt(localGid)];
		[self writeProperties:tileProperties];
		[_xmlWriter writeEndElement];
	}];

	[_xmlWriter writeEndElement];
} /* writeTileset */

-(void) writeLayer:(KKTilemapLayer*)layer
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
	[_xmlWriter writeAttribute:@"width" value:intStringFromFloat(layer.tilemap.size.width)];
	[_xmlWriter writeAttribute:@"height" value:intStringFromFloat(layer.tilemap.size.height)];
	[_xmlWriter writeAttribute:@"opacity" value:stringFromFloat(layer.alpha)];
	[_xmlWriter writeAttribute:@"visible" value:stringFromInt(!layer.hidden)];

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
		for (KKTilemapObject* object in layer.objects)
		{
			[self writeObject:object];
		}
	}

	[_xmlWriter writeEndElement];
} /* writeLayer */

// returns a base64, zlib compressed tile data string
-(NSString*) encodedDataStringFromTileLayer:(KKTilemapLayer*)layer
{
	size_t bufferSize = compressBound(layer.tiles.bytes);
	unsigned char* buffer = malloc(bufferSize);
	NSAssert2(buffer, @"KTTMXWriter: failed to allocate %u bytes for tile layer (%@) data", (unsigned int)bufferSize, layer);

	int result = compress(buffer, &bufferSize, (unsigned char*)layer.tiles.gid, layer.tiles.bytes);
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

-(void) writeObject:(KKTilemapObject*)object
{
DEVELOPER_TODO("TMX write ellipse objects")
	
	[_xmlWriter writeStartElement:@"object"];
	[_xmlWriter writeAttribute:@"name" value:object.name];
	[_xmlWriter writeAttribute:@"type" value:object.type];
	[_xmlWriter writeAttribute:@"x" value:intStringFromFloat(object.position.x)];
	[_xmlWriter writeAttribute:@"visible" value:stringFromInt(!object.hidden)];

	float yPos = (_tilemap.size.height * _tilemap.gridSize.height) - object.position.y;
	if (object.objectType == KKTilemapObjectTypeRectangle)
	{
		yPos -= object.size.height;
	}

	[_xmlWriter writeAttribute:@"y" value:intStringFromFloat(yPos)];

	if (object.rotation != 0.0)
	{
		[_xmlWriter writeAttribute:@"rotation" value:stringFromFloat(KK_RAD2DEG(object.rotation) * -1.0 + 180.0)];
	}
	
	if (CGSizeEqualToSize(object.size, CGSizeZero) == NO)
	{
		[_xmlWriter writeAttribute:@"width" value:intStringFromFloat(object.size.width)];
		[_xmlWriter writeAttribute:@"height" value:intStringFromFloat(object.size.height)];
	}

	// [_xmlWriter writeAttribute:@"visible" value:stringFromInt(object.visible)];

	[self writeProperties:object.properties];

	// write specific subclasses
	if (object.objectType == KKTilemapObjectTypePolygon || object.objectType == KKTilemapObjectTypePolyLine)
	{
		[_xmlWriter writeStartElement:(object.objectType == KKTilemapObjectTypePolygon ? @"polygon" : @"polyline")];
		[self writePolyObjectPoints:(KKTilemapPolyObject*)object];
		[_xmlWriter writeEndElement];
	}

	[_xmlWriter writeEndElement];
} /* writeObject */

-(void) writePolyObjectPoints:(KKTilemapPolyObject*)polyObject
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

-(void) writeProperties:(KKTilemapProperties*)tilemapProperties
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

