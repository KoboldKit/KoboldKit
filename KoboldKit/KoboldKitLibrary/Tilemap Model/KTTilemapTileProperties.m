//
// KTTilemapTileProperties.m
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 21.01.13.
//
//



#import "KTTilemapTileProperties.h"
#import "KTTilemapProperties.h"
#import "KKMutableNumber.h"

@implementation KTTilemapTileProperties

-(id) init
{
	self = [super init];
	if (self)
	{
		_properties = [NSMutableDictionary dictionaryWithCapacity:16];
	}

	return self;
}

-(KTTilemapProperties*) propertiesForGid:(gid_t)gid
{
	return [_properties objectForKey:[NSNumber numberWithUnsignedInt:gid]];
}

-(KTTilemapProperties*) propertiesForGid:(gid_t)gid createNonExistingProperties:(BOOL)createNonExistingProperties
{
	KTTilemapProperties* properties = [self propertiesForGid:gid];
	if (properties == nil && createNonExistingProperties)
	{
		properties = [[KTTilemapProperties alloc] init];
		[_properties setObject:properties forKey:[NSNumber numberWithUnsignedInt:gid]];
	}

	return properties;
}

-(KTTilemapProperties*) propertiesForGid:(gid_t)gid setValue:(NSString*)string forKey:(NSString*)key
{
	KTTilemapProperties* properties = [self propertiesForGid:gid createNonExistingProperties:YES];
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

-(KTTilemapProperties*) propertiesForGid:(gid_t)gid setNumber:(KKMutableNumber*)number forKey:(NSString*)key
{
	KTTilemapProperties* properties = [self propertiesForGid:gid createNonExistingProperties:YES];
	[properties setNumber:number forKey:key];
	return properties;
}

-(KTTilemapProperties*) propertiesForGid:(gid_t)gid setString:(NSString*)string forKey:(NSString*)key
{
	KTTilemapProperties* properties = [self propertiesForGid:gid createNonExistingProperties:YES];
	[properties setString:string forKey:key];
	return properties;
}

@end

