//
//  OGWMap.m
//  OpenGW
//
//  Created by Steffen Itterheim on 15.09.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "OGWMap.h"

@implementation OGWMap

-(void) dealloc
{
	free(_map);
}

-(void) retainMap:(int32_t*)map width:(NSUInteger)width height:(NSUInteger)height
{
	free(_map);
	_map = map;
	_width = width;
	_height = height;
	_count = _width * _height;
	_bytes = _count * sizeof(int32_t);
}

-(int32_t) elementAtX:(NSUInteger)x y:(NSUInteger)y
{
	NSUInteger index = y * _width + x;
	if (index >= _count)
	{
		NSLog(@"elementAtX:%ul y:%ul is out of bounds (%ul, %ul)!",
			  (uint32_t)x, (uint32_t)y, (uint32_t)_width, (uint32_t)_height);
		return 0;
	}
	
	return _map[index];
}

// enumerate

@end
