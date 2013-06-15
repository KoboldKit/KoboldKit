//
// KTTMXWriter.h
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 02.02.13.
//
//


@class KTTilemap;
@class XMLWriter;

/** Internal use only. Writes a KTTilemap object to a file in TMX format. The resulting TMX can be opened in Tiled Map Editor
   or other tools/engines that support the TMX format. */
@interface KTTMXWriter : NSObject
{
	@private
	XMLWriter* _xmlWriter;
	__weak KTTilemap* _tilemap;
}

-(void) writeTMXFile:(NSString*)file tilemap:(KTTilemap*)tilemap;

@end

