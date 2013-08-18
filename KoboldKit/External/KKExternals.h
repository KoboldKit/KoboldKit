//
//  KKExternals.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 17.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#ifndef KoboldKit_KKExternals_h
#define KoboldKit_KKExternals_h

// import all external headers here
#import "CCProfiling.h"
#import "CDSimpleAudioEngine.h"
#import "CGPointExtension.h"
#import "CGVectorExtension.h"
#import "KKArcadeInputState.h"
#import "Reachability.h"
#import "VTPG_Common.h"
#import "XMLWriter.h"
#import "ZipUtils.h"

// Lua
// if compiled as (Objective) C++ code the includes must be inside an extern "C" declaration
#ifdef __cplusplus
extern "C" {
#endif // __cplusplus
#include "lua.h"
#include "lauxlib.h"
#include "lobject.h"
#include "lualib.h"
#ifdef __cplusplus
}
#endif // __cplusplus

#endif
