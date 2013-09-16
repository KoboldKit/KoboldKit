//
//  OGWMap.h
//  OpenGW
//
//  Created by Steffen Itterheim on 15.09.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OGWMap : NSObject

@property (atomic, readonly) int32_t* map;
@property (atomic, readonly) NSUInteger width;
@property (atomic, readonly) NSUInteger height;
@property (atomic, readonly) NSUInteger count;
@property (atomic, readonly) NSUInteger bytes;

-(void) retainMap:(int32_t*)map width:(NSUInteger)width height:(NSUInteger)height;

-(int32_t) elementAtX:(NSUInteger)x y:(NSUInteger)y;

@end
