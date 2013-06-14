//
//
// Created by Steffen Itterheim on 28.09.12.
//
//

#ifndef KoboldKitLibrary_KTTypes_h
#define KoboldKitLibrary_KTTypes_h

/** @file KKTypes.h */

/** gid (globally unique tile index) is an unsigned int (32 bit) value */
typedef uint32_t        gid_t;

#if TARGET_OS_IPHONE
typedef UIEvent         KTEvent;
typedef UITouch         KTTouch;
typedef UIView          KTCocoaView;
typedef UIWindow        KTCocoaWindow;
typedef UIApplication   KTApplication;

#elif TARGET_OS_MAC
typedef NSEvent         KTEvent;
typedef NSTouch         KTTouch;
typedef NSView          KTCocoaView;
typedef NSWindow        KTCocoaWindow;
typedef NSApplication   KTApplication;
#endif // TARGET_OS_MAC

/** Converts a string to a CGPoint. Same as CGPointFromString/NSPointFromString but works on both platforms. */
static inline CGPoint pointFromString(NSString* pointString)
{
#if TARGET_OS_IPHONE
	return CGPointFromString(pointString);
#elif TARGET_OS_MAC
	return NSPointFromString(pointString);
#endif
}

/** Converts a string to a CGSize. Same as CGSizeFromString/NSSizeFromString but works on both platforms. */
static inline CGSize sizeFromString(NSString* pointString)
{
#if TARGET_OS_IPHONE
	return CGSizeFromString(pointString);
#elif TARGET_OS_MAC
	return NSSizeFromString(pointString);
#endif
}

/** Converts a string to a CGRect. Same as CGRectFromString/NSRectFromString but works on both platforms. */
static inline CGRect rectFromString(NSString* pointString)
{
#if TARGET_OS_IPHONE
	return CGRectFromString(pointString);
#elif TARGET_OS_MAC
	return NSRectFromString(pointString);
#endif
}

#endif
