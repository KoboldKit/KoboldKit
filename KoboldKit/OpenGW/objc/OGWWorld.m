//
//  OGWWorld.m
//  KoboldKitPro
//
//  Created by Steffen Itterheim on 14.09.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "OGWWorld.h"
#import "OGWTypes.h"

@implementation OGWWorld

-(id) init
{
	self = [super init];
	if (self)
	{
		_entities = [NSMutableDictionary dictionary];
		_maps = [NSMutableDictionary dictionary];
	}
	return self;
}

#pragma mark Entities

-(NSArray*) entitiesWithType:(NSInteger)entityType
{
	id array = [_entities objectForKey:[NSNumber numberWithInteger:entityType]];
	return array;
}

#pragma mark Maps

-(void) addMap:(OGWMap*)map forKey:(NSString*)key
{
	[_maps setObject:map forKey:key];
}

-(void) removeMapForKey:(NSString*)key
{
	[_maps removeObjectForKey:key];
}

-(OGWMap*) mapForKey:(NSString*)key
{
	return [_maps objectForKey:key];
}

@end
