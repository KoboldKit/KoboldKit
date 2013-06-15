//
// KTTMXReader.h
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 20.12.12.
//
//
// TMX Parser Code adapted from CCTMXXMLParser and related CCTMX* classes. This is the related copyright notice:
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


#import "KKTypes.h"

/** @file KTTMXReader.h */

@class KTTilemap;
@class KTTilemapTileset;
@class KTTilemapLayer;
@class KTTilemapObject;

typedef enum
{
	KTTilemapParsingElementNone,
	KTTilemapParsingElementMap,
	KTTilemapParsingElementLayer,
	KTTilemapParsingElementObjectGroup,
	KTTilemapParsingElementObject,
	KTTilemapParsingElementTile,
	KTTilemapParsingElementTileset,
} KTTilemapParsingElement;

typedef enum
{
	KTTilemapDataFormatNone = 1 << 0,
		KTTilemapDataFormatBase64 = 1 << 1,
		KTTilemapDataFormatGzip = 1 << 2,
		KTTilemapDataFormatZlib = 1 << 3,
} KTTilemapDataFormat;

/** Internal use only. Temporary object that parses a TMX file and creates the KTTilemap hierarchy containing KTTilemapTileset,
   KTTilemapLayer, KTTilemapLayerTiles and KTTilemapObject. Used by KTTilemap which has its own parseTMX method. Not meant to be subclassed
   or modified. */
@interface KTTMXReader : NSObject<NSXMLParserDelegate>
{
	@private
	KTTilemap* _tilemap;
	NSString* _tmxFile;
	NSMutableString* _dataString;
	NSNumberFormatter* _numberFormatter;

	KTTilemapTileset* _parsingTileset;
	KTTilemapLayer* _parsingLayer;
	KTTilemapObject* _parsingObject;
	gid_t _parsingTileGid;
	KTTilemapParsingElement _parsingElement;
	KTTilemapDataFormat _dataFormat;
	BOOL _parsingData;
}

-(void) parseTMXFile:(NSString*)tmxFile tilemap:(KTTilemap*)tilemap;

@end

