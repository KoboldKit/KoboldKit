/*
 * Copyright (c) 2011-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "../KoboldKitExternal/External/lua/LuaImport.h"

#define BEGIN_STACK_MODIFY(L)  int __startStackIndex = lua_gettop((L));
#define END_STACK_MODIFY(L, i) while (lua_gettop((L)) > (__startStackIndex + (i))) {lua_remove((L), __startStackIndex + 1); }
#define CLEAR_STACK(L)         lua_pop((L), lua_gettop((L)));

inline lua_State* currentLuaState();

/** @name Debug Helpers */
/** Prints the stack of the Lua state to the debug log. */
void lua_printStack(lua_State* L);
/** Prints the stack of the Lua state starting at index to the debug log. */
void lua_printStackAt(lua_State* L, int i);

// void wax_printTable(lua_State *L, int t);
// void wax_log(int flag, NSString *format, ...);
// int wax_errorFunction(lua_State *L);
// int wax_pcall(lua_State *L, int argumentCount, int returnCount);

/** Static class containing various Lua related helper methods. */
@interface KKLua : NSObject

/** One-time setup of Lua. Automatically called by the Kobold Kit framework. */
+(void) setup;

/** @returns The current lua state. Needed only for custom Lua code. */
+(lua_State*) luaState;

/** @name Execute Scripts */

/** Runs the Lua script file. File is a filename with or without path to the file, and with extension.
   Returns YES if the execution was successful and NO if it failed. Note that this is different from Lua,
   where a return value of 0 indicates success and 1 or higher indicates an error. But YES == success
   is more natural for Objective-C programmers.
 @param aFile The full path to a Lua script file.
 @returns YES if the file was found and the script was executed without errors. */
+(BOOL) doFile:(NSString*)aFile;

/** Runs the Lua code passed in as string.
   Returns YES if the execution was successful and NO if it failed. Note that this is different from Lua,
   where a return value of 0 indicates success and 1 or higher indicates an error. But YES == success
   is more natural for Objective-C programmers.
 @param aString A Lua script as string.
 @returns YES if the string was executed without errors. */
+(BOOL) doString:(NSString*)aString;

/** @name Error Handling */

/*   Returns the Class with the same name of a Lua script. First, it checks if the class already exists, and if so it returns the existing class.
   Otherwise it will doFile the lua script scriptName.lua and create a waxClass with the given superClass to create this class. On the next call the class
   will already exist and the script isn't called a second time. */
// +(Class) classFromLuaScriptWithName:(NSString*)scriptName superClass:(NSString*)superClass;

/** Logs the most recent Lua error by getting the error message string from the stack index -1 and displaying it. */
+(void) logLuaError;

/** Logs a Lua error with a custom message.
 @param aMessage The custom message to append to the log. */
+(void) logLuaErrorWithMessage:(NSString*)aMessage;

@end
