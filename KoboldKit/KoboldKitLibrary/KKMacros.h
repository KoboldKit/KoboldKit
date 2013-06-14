//
//  KKMacros.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#ifndef KoboldKitDemo_KKMacros_h
#define KoboldKitDemo_KKMacros_h

#import "float.h"

/** @file KKMacros.h */

#if TARGET_OS_IPHONE
typedef UIResponder KKResponder;
#elif TARGET_OS_MAC
typedef NSResponder KKResponder;
#endif

#if CGFLOAT_IS_DOUBLE
#define EPSILON_VALUE DBL_EPSILON
#else
#define EPSILON_VALUE FLT_EPSILON
#endif

#define CGFloatEqualToFloat(__x, __y) (fabs(__x - __y) <= (fabs(__x) > fabs(__y) ? fabs(__y) : fabs(__x)) * EPSILON_VALUE)

#endif
