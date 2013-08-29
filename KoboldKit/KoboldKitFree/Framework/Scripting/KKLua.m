/*
 * Copyright (c) 2011-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKLua.h"

static lua_State* luaState;

lua_State* currentLuaState()
{
	if (!luaState)
	{
		luaState = luaL_newstate();
	}

	return luaState;
}

int lua_panic(lua_State* L)
{
	printf("Lua panicked and quit, message: %s\n", luaL_checkstring(L, -1));
	exit(EXIT_FAILURE);
}

lua_CFunction lua_atpanic(lua_State* L, lua_CFunction panicf);

void lua_setup()
{
	lua_State* L = currentLuaState();
	lua_atpanic(L, &lua_panic);

	luaL_openlibs(L);
}

void lua_printStack(lua_State* L)
{
	int i;
	int top = lua_gettop(L);

	for (i = 1; i <= top; i++)
	{
		printf("%d: ", i);
		lua_printStackAt(L, i);
		printf("\n");
	}

	printf("\n");
}

void lua_printStackAt(lua_State* L, int i)
{
	int t = lua_type(L, i);
	printf("(%s) ", lua_typename(L, t));

	switch (t)
	{
		case LUA_TSTRING:
			printf("'%s'", lua_tostring(L, i));
			break;

		case LUA_TBOOLEAN:
			printf(lua_toboolean(L, i) ? "true" : "false");
			break;

		case LUA_TNUMBER:
			printf("'%g'", lua_tonumber(L, i));
			break;

		default:
			printf("%p", lua_topointer(L, i));
			break;
	} /* switch */
}


@implementation KKLua

+(void) setup
{
	if (luaState == nil)
	{
		lua_setup();
		[self doString:@"YES = true; NO = false;"];
	}
}

+(lua_State*) luaState
{
	return luaState;
}

+(void) logLuaError
{
	lua_State* L = currentLuaState();
	int top = lua_gettop(L);

	NSString* message = nil;
	if (lua_isstring(L, top))
	{
		const char* str = luaL_checkstring(L, top);
		message = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
		lua_pop(L, 1);
	}
	else
	{
		message = @"(error without message)";
	}

	NSLog(@"Lua error: %@", message);

#if TARGET_OS_IPHONE
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Lua Error"
													message:message
												   delegate:nil
						                  cancelButtonTitle:@"$#@&%!"
										  otherButtonTitles:nil];
	[alert show];
#else
	NSAlert* alert = [NSAlert alertWithMessageText:@"Lua Error"
									 defaultButton:@"$#@&%!"
								   alternateButton:nil
									   otherButton:nil
					     informativeTextWithFormat:@"%@", message];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert runModal];
#endif
}

+(void) logLuaErrorWithMessage:(NSString*)aMessage
{
	lua_State* L = currentLuaState();
	int top = lua_gettop(L);

	NSString* originalMessage = nil;
	if (lua_isstring(L, top))
	{
		const char* str = luaL_checkstring(L, top);
		originalMessage = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
		lua_pop(L, 1);

		aMessage = [NSString stringWithFormat:@"%@ (Lua error message: %@)", aMessage, originalMessage];
	}

	lua_pushstring(L, [aMessage cStringUsingEncoding:NSUTF8StringEncoding]);
	[KKLua logLuaError];
} /* logLuaErrorWithMessage */

+(id) returnValue
{
	id retval = nil;

	/*
	   if (lua_istable(currentLuaState(), 1))
	   {
	        id* objc = wax_copyToObjc(currentLuaState(), @encode(id), 1, nil);
	        retval = *objc;
	        lua_pop(currentLuaState(), 1);
	        wax_printStack(currentLuaState());
	   }
	 */

	return retval;
}

+(BOOL) doFile:(NSString*)aFile
{
	NSAssert1(aFile != nil, @"%@: file is nil", NSStringFromSelector(_cmd));

	BOOL success = NO;
	if (aFile && [[NSFileManager defaultManager] fileExistsAtPath:aFile])
	{
		const char* cfile = [aFile cStringUsingEncoding:NSUTF8StringEncoding];
		NSAssert1(cfile != nil, @"%@: C file is nil, possible encoding failure", NSStringFromSelector(_cmd));

		success = (luaL_dofile(currentLuaState(), cfile) == 0);
		if (success == NO)
		{
			[KKLua logLuaError];
		}
	}

	return success;
} /* doFile */

+(BOOL) doString:(NSString*)aString
{
	NSAssert1(aString != nil, @"%@: string is nil", NSStringFromSelector(_cmd));

	const char* cstring = [aString cStringUsingEncoding:NSUTF8StringEncoding];
	NSAssert1(cstring != nil, @"%@: C string is nil, possible encoding failure", NSStringFromSelector(_cmd));

	BOOL success = (luaL_dostring(currentLuaState(), cstring) == 0);
	if (success == NO)
	{
		[KKLua logLuaError];
	}

	return success;
}

@end
