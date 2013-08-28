/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

// Adapted and improved TMX Parser Code based on CCTMXXMLParser and related CCTMX* classes from cocos2d-iphone:

/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "KKTMXReader.h"
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


@implementation KKTMXReader

-(id) init
{
	self = [super init];
	if (self)
	{
		_numberFormatter = [[NSNumberFormatter alloc] init];
		[_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		// Why not make it locale-aware? Because it would make TMX maps created by US developers unusable by
		// devs in other countries whose decimal separator is not a dot but a comma.
		[_numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
	}

	return self;
}

-(void) loadTMXFile:(NSString*)tmxFile tilemap:(KKTilemap*)tilemap
{
	_tilemap = tilemap;
	_tmxFile = tmxFile;

	NSURL* url = [NSURL fileURLWithPath:_tmxFile];
	NSData* data = [NSData dataWithContentsOfURL:url];
	if (data)
	{
		[self parseTMXWithData:data];
	}

	_tmxFile = nil;
}

-(void) parseTMXString:(NSString*)tmxString
{
	NSData* data = [tmxString dataUsingEncoding:NSUTF8StringEncoding];
	[self parseTMXWithData:data];
}

-(void) parseTMXWithData:(NSData*)data
{
	NSAssert(data, @"can't parse TMX, data is nil");

	_dataString = [NSMutableString stringWithCapacity:4096];

	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
	parser.shouldProcessNamespaces = NO;
	parser.shouldReportNamespacePrefixes = NO;
	parser.shouldResolveExternalEntities = NO;
	[parser parse];

	_dataString = nil;
	_parsingLayer = nil;
	_parsingObject = nil;
	_parsingTileset = nil;
} /* parseTMXWithData */

-(void) parseMapWithAttributes:(NSDictionary*)attributes
{
	NSAssert([[attributes objectForKey:@"version"] isEqualToString:@"1.0"],
			 @"unsupported TMX version: %@", [attributes objectForKey:@"version"]);

	NSString* orientationAttribute = [attributes objectForKey:@"orientation"];
	if ([orientationAttribute isEqualToString:@"orthogonal"])
	{
		_tilemap.orientation = KKTilemapOrientationOrthogonal;
	}
	else if ([orientationAttribute isEqualToString:@"isometric"])
	{
		_tilemap.orientation = KKTilemapOrientationIsometric;
	}
	else if ([orientationAttribute isEqualToString:@"staggered"])
	{
		_tilemap.orientation = KKTilemapOrientationStaggeredIsometric;
	}
	else if ([orientationAttribute isEqualToString:@"hexagonal"])
	{
		_tilemap.orientation = KKTilemapOrientationHexagonal;
	}
	else
	{
		[NSException raise:@"unsupported TMX orientation" format:@"unsupported TMX orientation: %@", orientationAttribute];
	}

	CGSize mapSize;
	mapSize.width = [[attributes objectForKey:@"width"] intValue];
	mapSize.height = [[attributes objectForKey:@"height"] intValue];
	_tilemap.size = mapSize;

	CGSize gridSize;
	gridSize.width = [[attributes objectForKey:@"tilewidth"] intValue];
	gridSize.height = [[attributes objectForKey:@"tileheight"] intValue];
	_tilemap.gridSize = gridSize;

	NSString* bgColor = [attributes objectForKey:@"backgroundcolor"];
	if (bgColor)
	{
		NSScanner* scanner = [NSScanner scannerWithString:[bgColor substringFromIndex:1]];
		unsigned int hex;
		if ([scanner scanHexInt:&hex])
		{
			int r = (hex >> 16) & 0xFF;
			int g = (hex >>  8) & 0xFF;
			int b = (hex      ) & 0xFF;

			_tilemap.backgroundColor = [SKColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0];
		}
	}
}

-(void) parseTilesetWithAttributes:(NSDictionary*)attributes
{
	// If this is an external tileset then start parsing that
	NSString* externalTilesetFilename = [attributes objectForKey:@"source"];
	if (externalTilesetFilename)
	{
		// Tileset file will be relative to the map file. So we need to convert it to an absolute path
		NSString* dir = [_tmxFile stringByDeletingLastPathComponent];
		externalTilesetFilename = [dir stringByAppendingPathComponent:externalTilesetFilename];
		[self loadTMXFile:externalTilesetFilename tilemap:_tilemap];
	}
	else
	{
		KKTilemapTileset* tileset = [[KKTilemapTileset alloc] init];
		tileset.name = [attributes objectForKey:@"name"];
		tileset.firstGid = (gid_t)[[attributes objectForKey:@"firstgid"] intValue];
		tileset.spacing = [[attributes objectForKey:@"spacing"] intValue];
		tileset.margin = [[attributes objectForKey:@"margin"] intValue];
		// tileset.transparentColor = [attributes objectForKey:@"trans"];
		CGSize tileSize;
		tileSize.width = [[attributes objectForKey:@"tilewidth"] intValue];
		tileSize.height = [[attributes objectForKey:@"tileheight"] intValue];
		tileset.tileSize = tileSize;
		[_tilemap addTileset:tileset];
		_parsingTileset = tileset;
	}
}

-(void) parseTilesetTileOffsetWithAttributes:(NSDictionary*)attributes
{
	CGPoint offset;
	offset.x = [[attributes objectForKey:@"x"] intValue];
	offset.y = [[attributes objectForKey:@"y"] intValue];
	_parsingTileset.drawOffset = offset;
}

-(void) parseTilesetImageWithAttributes:(NSDictionary*)attributes
{
	NSString* source = [attributes objectForKey:@"source"];
	_parsingTileset.imageFile = [source lastPathComponent];
}

-(void) parseTilesetTileWithAttributes:(NSDictionary*)attributes
{
	_parsingTileGid = _parsingTileset.firstGid + (gid_t)[[attributes objectForKey:@"id"] intValue];
}

-(void) parseLayerWithAttributes:(NSDictionary*)attributes
{
	KKTilemapLayer* layer = [[KKTilemapLayer alloc] init];
	layer.tilemap = _tilemap;
	layer.isTileLayer = YES;
	layer.name = [attributes objectForKey:@"name"];
	layer.hidden = [[attributes objectForKey:@"visible"] isEqualToString:@"0"];
	
	KKMutableNumber* opacity = [attributes objectForKey:@"opacity"];
	layer.alpha = opacity ? [opacity floatValue] : 1.0;

	CGSize layerSize;
	layerSize.width = [[attributes objectForKey:@"width"] intValue];
	layerSize.height = [[attributes objectForKey:@"height"] intValue];
	layer.size = layerSize;
	layer.tileCount = layerSize.width * layerSize.height;
	[_tilemap addLayer:layer];

	_parsingLayer = layer;
	_parsingElement = KKTilemapParsingElementLayer;
}

-(void) parseImageLayerWithAttributes:(NSDictionary*)attributes
{
}

-(void) parseImageLayerImageWithAttributes:(NSDictionary*)attributes
{
}

-(void) parseObjectGroupWithAttributes:(NSDictionary*)attributes
{
	KKTilemapLayer* layer = [[KKTilemapLayer alloc] init];
	layer.tilemap = _tilemap;
	layer.isObjectLayer = YES;
	layer.name = [attributes objectForKey:@"name"];
	layer.alpha = 255;
	NSString* opacity = [attributes objectForKey:@"opacity"];
	if (opacity)
	{
		layer.alpha = (unsigned char)(255.0f* [opacity floatValue]);
	}

	// Tiled quirk: object layers only write visible="0" to TMX when not visible, otherwise visible is simply omitted from TMX file
	layer.hidden = [[attributes objectForKey:@"visible"] isEqualToString:@"0"];

	[_tilemap addLayer:layer];

	_parsingLayer = layer;
	_parsingElement = KKTilemapParsingElementObjectGroup;
} /* parseObjectGroupWithAttributes */

-(void) parseObjectWithAttributes:(NSDictionary*)attributes
{
	KKTilemapObject* object = nil;

	// determine type of object first
	if ([attributes objectForKey:@"gid"])
	{
		KKTilemapTileObject* tileObject = [[KKTilemapTileObject alloc] init];
		tileObject.gid = (gid_t)[[attributes objectForKey:@"gid"] intValue];
		tileObject.size = _tilemap.gridSize;
		object = tileObject;
	}
	else if ([attributes objectForKey:@"width"] || [attributes objectForKey:@"height"])
	{
		KKTilemapRectangleObject* rectObject = [[KKTilemapRectangleObject alloc] init];
		rectObject.size = CGSizeMake([[attributes objectForKey:@"width"] intValue], [[attributes objectForKey:@"height"] intValue]);
		object = rectObject;
	}
	else
	{
		KKTilemapPolyObject* polyObject = [[KKTilemapPolyObject alloc] init];
		polyObject.objectType = KKTilemapObjectTypeUnset; // it could be a zero-sized rectangle object
		object = polyObject;
	}

	object.layer = _parsingLayer;
	object.name = [attributes objectForKey:@"name"];
	object.type = [attributes objectForKey:@"type"];
	object.hidden = [[attributes objectForKey:@"visible"] isEqualToString:@"0"];
	
	NSString* rotation = [attributes objectForKey:@"rotation"];
	if (rotation)
	{
		NSNumber* number = [_numberFormatter numberFromString:rotation];
		object.rotation = KK_DEG2RAD(180.0 + number.doubleValue * -1.0);
	}

	CGPoint position;
	position.x = [[attributes objectForKey:@"x"] intValue];
	position.y = [[attributes objectForKey:@"y"] intValue];
	// Correct y position. (Tiled uses Y origin on top extending downward, cocos2d has Y origin at bottom extending upward)
	position.y = (_tilemap.size.height * _tilemap.gridSize.height) - position.y;
	if (object.objectType == KKTilemapObjectTypeRectangle)
	{
		// rectangles have their origin point at the upper left corner, but we need it to be in the lower left corner
		position.y -= object.size.height;
	}

	object.position = position;

	_parsingObject = object;
	_parsingElement = KKTilemapParsingElementObject;
} /* parseObjectWithAttributes */

-(void) parsePolygonWithAttributes:(NSDictionary*)attributes
{
	[(KKTilemapPolyObject*)_parsingObject makePointsFromString:[attributes objectForKey:@"points"]];
	_parsingObject.objectType = KKTilemapObjectTypePolygon;
}

-(void) parsePolyLineWithAttributes:(NSDictionary*)attributes
{
	[(KKTilemapPolyObject*)_parsingObject makePointsFromString:[attributes objectForKey:@"points"]];
	_parsingObject.objectType = KKTilemapObjectTypePolyLine;
}

-(void) parseEllipseWithAttributes:(NSDictionary*)attributes
{
	((KKTilemapRectangleObject*)_parsingObject).ellipse = YES;
	_parsingObject.objectType = KKTilemapObjectTypeEllipse;

DEVELOPER_FIXME("ellipse position/anchor is not correct")
	//_parsingObject.position = CGPointMake(_parsingObject.position.x + _tilemap.gridSize.width, _parsingObject.position.y + _parsingObject.size.height);
}

-(void) addParsingObjectToLayer
{
	// Add the object to the object Layer
	NSAssert2(_parsingLayer.isObjectLayer, @"ERROR adding object %@: parsing layer (%@) is not an object layer", _parsingObject, _parsingLayer);
	if (_parsingObject.objectType == KKTilemapObjectTypeUnset)
	{
		// we have a zero-sized rectangle object, replace parsing object
		_parsingObject = [_parsingObject rectangleObjectFromPolyObject:(KKTilemapPolyObject*)_parsingObject];
	}

	[_parsingLayer addObject:_parsingObject];
}

-(void) parsePropertyWithAttributes:(NSDictionary*)attributes
{
	switch (_parsingElement)
	{
		case KKTilemapParsingElementMap:
		{
			[_tilemap.properties setValue:[attributes objectForKey:@"value"] forKey:[attributes objectForKey:@"name"]];
			break;
		}

		case KKTilemapParsingElementLayer:
		case KKTilemapParsingElementObjectGroup:
		{
			[_parsingLayer.properties setValue:[attributes objectForKey:@"value"] forKey:[attributes objectForKey:@"name"]];
			break;
		}

		case KKTilemapParsingElementObject:
		{
			[_parsingObject.properties setValue:[attributes objectForKey:@"value"] forKey:[attributes objectForKey:@"name"]];
			break;
		}

		case KKTilemapParsingElementTile:
		{
			[_parsingTileset.tileProperties propertiesForGid:_parsingTileGid setValue:[attributes objectForKey:@"value"] forKey:[attributes objectForKey:@"name"]];
			break;
		}

		case KKTilemapParsingElementTileset:
		{
			[_parsingTileset.properties setValue:[attributes objectForKey:@"value"] forKey:[attributes objectForKey:@"name"]];
			break;
		}

		default:
			NSLog(@"TMX Parser: parsing element is unsupported. Cannot add attribute named '%@' with value '%@'",
				  [attributes objectForKey:@"name"], [attributes objectForKey:@"value"]);
			break;
	} /* switch */
}     /* parsePropertyWithAttributes */

-(void) parseDataWithAttributes:(NSDictionary*)attributes
{
	NSString* encoding = [attributes objectForKey:@"encoding"];
	NSString* compression = [attributes objectForKey:@"compression"];

	NSAssert([encoding isEqualToString:@"base64"], @"TMX tile layers must be Base64 encoded. Change the encoding in Tiled preferences.");
	NSAssert1([compression isEqualToString:@"gzip"] || [compression isEqualToString:@"zlib"],
			  @"TMX: unsupported tile layer compression method: %@. Change compression in Tiled preferences, zlib is recommended.", compression);

	if ([encoding isEqualToString:@"base64"])
	{
		_parsingData = YES;
		_dataFormat |= KKTilemapDataFormatBase64;

		if ([compression isEqualToString:@"gzip"])
		{
			_dataFormat |= KKTilemapDataFormatGzip;
		}
		else if ([compression isEqualToString:@"zlib"])
		{
			_dataFormat |= KKTilemapDataFormatZlib;
		}
	}
} /* parseDataWithAttributes */

-(void) loadTileLayerTiles
{
	unsigned char* tileGidBuffer;
	unsigned int tileGidBufferSize = base64Decode((unsigned char*)[_dataString UTF8String], (unsigned int)_dataString.length, &tileGidBuffer);
	if (tileGidBuffer == NULL)
	{
		[NSException raise:@"TMX decode error" format:@"TMX base64 decoding of layer (%@) failed", _parsingLayer];
	}

	if (_dataFormat & (KKTilemapDataFormatGzip | KKTilemapDataFormatZlib))
	{
		// deflate the buffer if it is in compressed format
		unsigned char* deflatedTileGidBuffer;
		CGSize mapSize = _tilemap.size;
		unsigned int expectedSize = mapSize.width * mapSize.height * sizeof(gid_t);
		unsigned int deflatedTileGidBufferSize = ccInflateMemoryWithHint(tileGidBuffer, tileGidBufferSize, &deflatedTileGidBuffer, expectedSize);
		NSAssert2(deflatedTileGidBufferSize == expectedSize, @"TMX data decode: hint mismatch! (got: %i, expected: %i)", deflatedTileGidBufferSize, expectedSize);

		// free the compressed buffer, we don't need this anymore
		free(tileGidBuffer);

		if (deflatedTileGidBuffer == NULL)
		{
			[NSException raise:@"TMX deflate error" format:@"TMX deflating gzip/zlib data of layer (%@) failed", _parsingLayer];
		}

		[_parsingLayer.tiles takeOwnershipOfGidBuffer:(gid_t*)deflatedTileGidBuffer bufferSize:deflatedTileGidBufferSize];
	}
	else
	{
		// the buffer is not compressed and can be used directly
		[_parsingLayer.tiles takeOwnershipOfGidBuffer:(gid_t*)tileGidBuffer bufferSize:tileGidBufferSize];
	}

	[_dataString setString:@""];
	_parsingData = NO;
}

-(void)  parser:(NSXMLParser*)parser
didStartElement:(NSString*)elementName
   namespaceURI:(NSString*)namespaceURI
  qualifiedName:(NSString*)qualifiedName
	 attributes:(NSDictionary*)attributes
{
	// sorted by expected number of appearances in an average TMX file
	if ([elementName isEqualToString:@"object"])
	{
		[self parseObjectWithAttributes:attributes];
	}
	else if ([elementName isEqualToString:@"polygon"])
	{
		[self parsePolygonWithAttributes:attributes];
	}
	else if ([elementName isEqualToString:@"polyline"])
	{
		[self parsePolyLineWithAttributes:attributes];
	}
	else if ([elementName isEqualToString:@"ellipse"])
	{
		[self parseEllipseWithAttributes:attributes];
	}
	else if ([elementName isEqualToString:@"property"])
	{
		[self parsePropertyWithAttributes:attributes];
	}
	else if ([elementName isEqualToString:@"tileset"])
	{
		[self parseTilesetWithAttributes:attributes];
		_parsingElement = KKTilemapParsingElementTileset;
	}
	else if ([elementName isEqualToString:@"image"])
	{
		switch (_parsingElement)
		{
			case KKTilemapParsingElementTileset:
				[self parseTilesetImageWithAttributes:attributes];
				break;
			case KKTilemapParsingElementImageLayer:
				[self parseImageLayerImageWithAttributes:attributes];
				break;
			default:
				[NSException raise:NSInternalInconsistencyException format:@"unhandled _parsingElement: %u", _parsingElement];
				break;
		}
	}
	else if ([elementName isEqualToString:@"tile"])
	{
		[self parseTilesetTileWithAttributes:attributes];
		_parsingElement = KKTilemapParsingElementTile;
	}
	else if ([elementName isEqualToString:@"layer"])
	{
		[self parseLayerWithAttributes:attributes];
	}
	else if ([elementName isEqualToString:@"data"])
	{
		[self parseDataWithAttributes:attributes];
	}
	else if ([elementName isEqualToString:@"objectgroup"])
	{
		[self parseObjectGroupWithAttributes:attributes];
	}
	else if ([elementName isEqualToString:@"imagelayer"])
	{
		[self parseImageLayerWithAttributes:attributes];
		_parsingElement = KKTilemapParsingElementImageLayer;
	}
	else if ([elementName isEqualToString:@"tileoffset"])
	{
		[self parseTilesetTileOffsetWithAttributes:attributes];
	}
	else if ([elementName isEqualToString:@"map"])
	{
		[self parseMapWithAttributes:attributes];
		_parsingElement = KKTilemapParsingElementMap;
	}
}

-(void) parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qualifiedName
{
	if ([elementName isEqualToString:@"data"] && (_dataFormat & KKTilemapDataFormatBase64))
	{
		[self loadTileLayerTiles];
	}
	else if ([elementName isEqualToString:@"object"] ||
			 [elementName isEqualToString:@"tile"] ||
			 [elementName isEqualToString:@"objectgroup"] ||
			 [elementName isEqualToString:@"layer"] ||
			 [elementName isEqualToString:@"tileset"] ||
			 [elementName isEqualToString:@"imagelayer"] ||
			 [elementName isEqualToString:@"map"])
	{
		if (_parsingElement == KKTilemapParsingElementObject)
		{
			[self addParsingObjectToLayer];
		}

		_parsingElement = KKTilemapParsingElementNone;
	}
}

-(void) parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
	if (_parsingData)
	{
		[_dataString appendString:string];
	}
}

-(void) parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError
{
	[NSException raise:@"TMX Parse Error!" format:@"TMX Parse Error! File: %@ - Description: %@ - Reason: %@ - Suggestion: %@",
	 _tmxFile, parseError.localizedDescription, parseError.localizedFailureReason, parseError.localizedRecoverySuggestion];
}

@end

