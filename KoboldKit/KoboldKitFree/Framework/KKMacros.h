/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

// Some code adopted from cocos2d-iphone:
/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "KKConfig.h"
#import "float.h"

/** @file KKMacros.h */

/** Enabling developer mode adds pragma messages for things one could fix, improve, add. */

#if SHOW_DEVELOPER_MESSAGES
#define PRAGMA_MESSAGE(x) _Pragma(#x)
// Callout to other developers. Use for messages that don't fit in the FIXME/TODO categories.
#define DEVELOPER_MESSAGE(msg) PRAGMA_MESSAGE(message msg)
// Implies suboptimal code that could be improved, made more flexible, elegant, faster.
#define DEVELOPER_FIXME(msg) PRAGMA_MESSAGE(message "FIXME: " msg)
// Implies something is missing, a feature that could be added.
#define DEVELOPER_TODO(msg) PRAGMA_MESSAGE(message "TODO: " msg)
#else
#define DEVELOPER_MESSAGE(msg)
#define DEVELOPER_FIXME(msg)
#define DEVELOPER_TODO(msg)
#endif



/** Epsilon and Float equality */
#if CGFLOAT_IS_DOUBLE
#define EPSILON_VALUE DBL_EPSILON
#else
#define EPSILON_VALUE FLT_EPSILON
#endif


/** "Is nearly equal" implementation for float/double values */
#define CGFloatEqualToFloat(__x, __y) (fabs(__x - __y) <= (fabs(__x) > fabs(__y) ? fabs(__y) : fabs(__x)) * EPSILON_VALUE)


/** Raise exception when a method with this macro isn't overridden in its subclass. */
#define KKMustOverrideMethod()      [NSException raise : NSInternalInconsistencyException format : @"%s must be overridden in subclass/category or you called [super %s]", __PRETTY_FUNCTION__, __PRETTY_FUNCTION__]
#define KKMethodUnavailable(reason) __attribute__((unavailable(reason)))


/** Radians to Degrees and vice versa */
#define M_PI_180			0.01745329251994	/* pi/180           */
#define M_180_PI			57.29577951308233	/* 180/pi           */
#define KK_DEG2RAD(__ANGLE__) ((__ANGLE__) * M_PI_180)
#define KK_RAD2DEG(__ANGLE__) ((__ANGLE__) * M_180_PI)


/** simple random */
#define KKRANDOM_MINUS1_1()              ((random() / (float)0x3fffffff) - 1.0f)
#define KKRANDOM_0_1()                   ((random() / (float)0x7fffffff))


/** Suppress a compiler warning regarding the performSelector: method. */
#define SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(code)                        \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")     \
code;                                                                   \
_Pragma("clang diagnostic pop")                                         \

#define SUPPRESS_DEPRECATED_WARNING(code) \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")     \
code;                                                                   \
_Pragma("clang diagnostic pop")                                         \

/** To save the boilerplate required */
#define SYNTHESIZE_DYNAMIC_PROPERTY(propertyName,setterName,propertyType,defaultValue) \
static propertyType _##propertyName = defaultValue;\
@dynamic propertyName;\
+(propertyType) propertyName { \
return _##propertyName; \
} \
-(propertyType) propertyName { \
return _##propertyName; \
} \
-(void) setterName:(propertyType)propertyName { \
_##propertyName = propertyName; \
} \
