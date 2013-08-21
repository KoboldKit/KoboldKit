//
//  SKNode+KoboldKitPro.m
//  KoboldKitPro
//
//  Created by Steffen Itterheim on 21.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "SKNode+KoboldKitPro.h"
#import "KKEntity.h"

@implementation SKNode (KoboldKitPro)

@dynamic tilemapObject;
-(void) setTilemapObject:(KKTilemapObject*)tilemapObject
{
	NSMutableDictionary* userData = self.userData;
	if (userData == nil)
	{
		self.userData = userData = [NSMutableDictionary dictionaryWithCapacity:1];
	}
	[userData setObject:tilemapObject forKey:@"KK:tilemapObject"];
}

-(KKTilemapObject*) tilemapObject
{
	return [self.userData objectForKey:@"KK:tilemapObject"];
}

@dynamic entity;
-(void) setEntity:(KKEntity*)entity
{
	NSMutableDictionary* userData = self.userData;
	if (userData == nil)
	{
		self.userData = userData = [NSMutableDictionary dictionaryWithCapacity:1];
	}
	[userData setObject:entity forKey:@"KK:entity"];
}

-(KKEntity*) entity
{
	return [self.userData objectForKey:@"KK:entity"];
}

@end
