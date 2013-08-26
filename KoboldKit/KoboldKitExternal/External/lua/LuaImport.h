//
//  Lua.h
//  KoboldKitExternal
//
//  Created by Steffen Itterheim on 26.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

// if compiled as (Objective) C++ code the includes must be inside an extern "C" declaration
#ifdef __cplusplus
extern "C" {
#endif // __cplusplus
	
#import "lua.h"
#import "lauxlib.h"
#import "lobject.h"
#import "lualib.h"
	
#ifdef __cplusplus
}
#endif // __cplusplus
