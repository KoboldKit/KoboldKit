/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

@class KKTilemap;
@class XMLWriter;

/** Internal use only. 
 Writes a KTTilemap object to a file in TMX format. The resulting TMX can be opened in Tiled Map Editor
   or other tools/engines that support the TMX format. */
@interface KKTMXWriter : NSObject
{
	@private
	XMLWriter* _xmlWriter;
	__weak KKTilemap* _tilemap;
}

/** Writes a KTTilemap object hierarchy to a file in TMX format.
 @param file The full path to a file.
 @param tilemap The KTTilemap object hierarchy to write. */
-(void) writeTMXFile:(NSString*)file tilemap:(KKTilemap*)tilemap;

@end

