/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTilemapTileProperties.h"
#import "KKTilemapProperties.h"
#import "KKMutableNumber.h"
#import "KKTilemap.h"

@implementation KKTilemapTileProperties

-(id) init
{
	self = [super init];
	if (self)
	{
		_properties = [NSMutableDictionary dictionary];
	}

	return self;
}

-(KKTilemapProperties*) propertiesForGid:(gid_t)gid
{
	gid_t gidWithoutFlags = (gid & KKTilemapTileFlipMask);
	return [_properties objectForKey:[NSNumber numberWithUnsignedInt:gidWithoutFlags]];
}

-(KKTilemapProperties*) propertiesForGid:(gid_t)gid createNonExistingProperties:(BOOL)createNonExistingProperties
{
	KKTilemapProperties* properties = [self propertiesForGid:gid];
	if (properties == nil && createNonExistingProperties)
	{
		properties = [[KKTilemapProperties alloc] init];
		gid_t gidWithoutFlags = (gid & KKTilemapTileFlipMask);
		[_properties setObject:properties forKey:[NSNumber numberWithUnsignedInt:gidWithoutFlags]];
	}

	return properties;
}

-(KKTilemapProperties*) propertiesForGid:(gid_t)gid setValue:(NSString*)string forKey:(NSString*)key
{
	KKTilemapProperties* properties = [self propertiesForGid:gid createNonExistingProperties:YES];
	KKMutableNumber* number = [properties numberFromString:string];
	if (number)
	{
		[properties setNumber:number forKey:key];
	}
	else
	{
		[properties setString:string forKey:key];
	}

	return properties;
}

-(KKTilemapProperties*) propertiesForGid:(gid_t)gid setNumber:(KKMutableNumber*)number forKey:(NSString*)key
{
	KKTilemapProperties* properties = [self propertiesForGid:gid createNonExistingProperties:YES];
	[properties setNumber:number forKey:key];
	return properties;
}

-(KKTilemapProperties*) propertiesForGid:(gid_t)gid setString:(NSString*)string forKey:(NSString*)key
{
	KKTilemapProperties* properties = [self propertiesForGid:gid createNonExistingProperties:YES];
	[properties setString:string forKey:key];
	return properties;
}

@dynamic count;
-(NSUInteger) count
{
	return _properties.count;
}

@end

