/*
 * Copyright (c) 2011-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKMutableNumber.h"
#import "KKLua.h"

@implementation NSDictionary (KoboldKit)

typedef enum
{
	kStructType_INVALID = 0,
	kStructTypePoint,
	kStructTypeSize,
	kStructTypeRect,
} EStructTypes;


+(float) floatFromTable:(lua_State*)state atIndex:(int)index
{
	lua_pushinteger(state, index);
	lua_gettable(state, -2);
	float f = (float)lua_tonumber(state, -1);
	lua_pop(state, 1);
	return f;
}

+(void) internalLoadSubTableWithKey:(NSString*)aKey
						   luaState:(lua_State*)theLuaState
						 dictionary:(NSMutableDictionary*)aDictionary
{
	// check if the table contains a "magic marker"
	lua_getfield(theLuaState, -1, "structType");
	int structType = (int)lua_tointeger(theLuaState, -1);
	lua_pop(theLuaState, 1);
	
	// create the appropriate NSValue type
	switch (structType)
	{
		case kStructTypePoint:
		{
			float x = [self floatFromTable:theLuaState atIndex:1];
			float y = [self floatFromTable:theLuaState atIndex:2];
#if TARGET_OS_IPHONE
			[aDictionary setObject:[NSValue valueWithCGPoint:CGPointMake(x, y)] forKey:aKey];
#else
			[aDictionary setObject:[NSValue valueWithPoint:NSMakePoint(x, y)] forKey:aKey];
#endif
			break;
		}
			
		case kStructTypeSize:
		{
			float width = [self floatFromTable:theLuaState atIndex:1];
			float height = [self floatFromTable:theLuaState atIndex:2];
#if TARGET_OS_IPHONE
			[aDictionary setObject:[NSValue valueWithCGSize:CGSizeMake(width, height)] forKey:aKey];
#else
			[aDictionary setObject:[NSValue valueWithSize:NSMakeSize(width, height)] forKey:aKey];
#endif
			break;
		}
			
		case kStructTypeRect:
		{
			float x = [self floatFromTable:theLuaState atIndex:1];
			float y = [self floatFromTable:theLuaState atIndex:2];
			float width = [self floatFromTable:theLuaState atIndex:3];
			float height = [self floatFromTable:theLuaState atIndex:4];
#if TARGET_OS_IPHONE
			[aDictionary setObject:[NSValue valueWithCGRect:CGRectMake(x, y, width, height)] forKey:aKey];
#else
			[aDictionary setObject:[NSValue valueWithRect:NSMakeRect(x, y, width, height)] forKey:aKey];
#endif
			break;
		}
			
		default:
		case kStructType_INVALID:
		{
			// assume it's a user table, recurse into it
			NSMutableDictionary* tableDict = [self internalRecursivelyLoadTable:theLuaState index:-1];
			if (tableDict != nil)
			{
				[aDictionary setObject:tableDict forKey:aKey];
			}
			
			break;
		}
	} /* switch */
}     /* internalLoadSubTableWithKey */

+(NSMutableDictionary*) internalRecursivelyLoadTable:(lua_State*)L index:(int)anIndex
{
	NSString* error = nil;
	NSMutableDictionary* dict = nil;
	
	if (lua_istable(L, anIndex))
	{
		dict = [NSMutableDictionary dictionaryWithCapacity:3];
		
		lua_pushnil(L); // first key
		while (lua_next(L, -2) != 0)
		{
			NSString* key = nil;
			if (lua_isnumber(L, -2))
			{
				int number = (int)lua_tonumber(L, -2);
				key = [NSString stringWithFormat:@"%i", number];
			}
			else if (lua_isstring(L, -2))
			{
				key = [NSString stringWithCString:lua_tostring(L, -2) encoding:NSUTF8StringEncoding];
			}
			else
			{
				error = @"key in table is neither string nor number!";
				break;
			}
			
			int luaValueType = lua_type(L, -1);
			switch (luaValueType)
			{
				case LUA_TNUMBER:
					[dict setObject:[KKMutableNumber numberWithDouble:lua_tonumber(L, -1)] forKey:key];
					break;

				case LUA_TBOOLEAN:
					[dict setObject:[KKMutableNumber numberWithBool:lua_toboolean(L, -1)] forKey:key];
					break;

				case LUA_TSTRING:
					[dict setObject:[NSString stringWithCString:lua_tostring(L, -1) encoding:NSUTF8StringEncoding] forKey:key];
					break;
					
				case LUA_TTABLE:
				{
					[self internalLoadSubTableWithKey:key luaState:L dictionary:dict];
					break;
				}
					
				default:
					NSLog(@"Unknown value type %i in table ignored.", luaValueType);
					break;
			} /* switch */
			
			lua_pop(L, 1);
		}
	}
	else
	{
		error = @"not a Lua table!";
	}
	
	if (error != nil)
	{
		NSLog(@"\n\nERROR in %@: %@\n\n", NSStringFromSelector(_cmd), error);
	}
	
	return dict;
}

+(NSDictionary*) dictionaryWithContentsOfLuaScript:(NSString*)luaScript
{
	return [NSMutableDictionary dictionaryWithContentsOfLuaScript:luaScript];
}

@end


@implementation NSMutableDictionary (KoboldKit)

+(NSMutableDictionary*) dictionaryWithContentsOfLuaScript:(NSString*)luaScript
{
	NSMutableDictionary* dict = nil;
	BOOL didLoadFile = [KKLua doFile:luaScript];
	
	if (didLoadFile)
	{
		lua_State* L = currentLuaState();
		if (lua_istable(L, -1))
		{
			dict = [self internalRecursivelyLoadTable:L index:-1];
			// LOG_EXPR(dict);
		}
		else
		{
			if (lua_isstring(L, -1))
			{
				NSString* error = [NSString stringWithCString:lua_tostring(L, -1) encoding:NSUTF8StringEncoding];
				NSLog(@"\n\nERROR in %@: %@\n\n", NSStringFromSelector(_cmd), error);
			}
		}
		
		lua_pop(L, 1);
	}
	
	return dict;
}

@end
