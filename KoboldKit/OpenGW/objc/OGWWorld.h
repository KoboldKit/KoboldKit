//
//  OGWWorld.h
//  KoboldKitPro
//
//  Created by Steffen Itterheim on 14.09.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGWEntity;
@class OGWMap;

@interface OGWWorld : NSObject
{
	@protected
	
	@private
	NSMutableDictionary* _entities;
	NSMutableDictionary* _maps;
}

-(NSArray*) entitiesWithType:(NSInteger)entityType;

-(void) addMap:(OGWMap*)map forKey:(NSString*)key;
-(void) removeMapForKey:(NSString*)key;
-(OGWMap*) mapForKey:(NSString*)key;


@end
