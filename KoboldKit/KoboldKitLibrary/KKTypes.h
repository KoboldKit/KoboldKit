//
// KTTypes.h
// Kobold2D-Libraries
//
// Created by Steffen Itterheim on 28.09.12.
//
//

#ifndef Kobold2D_Libraries_KTTypes_h
#define Kobold2D_Libraries_KTTypes_h

#import "ccMoreMacros.h"

/** @file KTTypes.h */

static NSString* const KTDirectorDidReshapeProjectionNotification = @"KTDirectorDidReshapeProjectionNotification";

/** gid (globally unique tile index) is an unsigned int (32 bit) value */
typedef uint32_t        gid_t;

#if KK_PLATFORM_IOS
typedef UIEvent         KTEvent;
typedef UITouch         KTTouch;
typedef UIView          KTCocoaView;
typedef UIWindow        KTCocoaWindow;
typedef UIApplication   KTApplication;

#elif KK_PLATFORM_MAC
typedef NSEvent         KTEvent;
typedef NSTouch         KTTouch;
typedef NSView          KTCocoaView;
typedef NSWindow        KTCocoaWindow;
typedef NSApplication   KTApplication;
#endif // KK_PLATFORM_MAC

/** A point with 3 coordinates. */
typedef struct
{
	CGFloat x;
	CGFloat y;
	CGFloat z;
} KTPoint3;

/** A "zero" KTPoint3 struct. */
static const KTPoint3 KTPoint3Zero = {
	0, 0, 0
};

/** Returns a new KTPoint3 struct. */
static inline KTPoint3 KTPoint3Make(CGFloat x, CGFloat y, CGFloat z)
{
	return (KTPoint3) {
			   x, y, z
	};
}

/** Converts a string to a CGPoint. Same as CGPointFromString/NSPointFromString but works on both platforms. */
static inline CGPoint pointFromString(NSString* pointString)
{
#if KK_PLATFORM_IOS
	return CGPointFromString(pointString);
#elif KK_PLATFORM_MAC
	return NSPointFromString(pointString);
#endif
}

/** Converts a string to a CGSize. Same as CGSizeFromString/NSSizeFromString but works on both platforms. */
static inline CGSize sizeFromString(NSString* pointString)
{
#if KK_PLATFORM_IOS
	return CGSizeFromString(pointString);
#elif KK_PLATFORM_MAC
	return NSSizeFromString(pointString);
#endif
}

/** Converts a string to a CGRect. Same as CGRectFromString/NSRectFromString but works on both platforms. */
static inline CGRect rectFromString(NSString* pointString)
{
#if KK_PLATFORM_IOS
	return CGRectFromString(pointString);
#elif KK_PLATFORM_MAC
	return NSRectFromString(pointString);
#endif
}

#endif // Kobold2D_Libraries_KTTypes_h
