/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


/** @file KKTypes.h */

/** gid (globally unique tile index) is an unsigned int (32 bit) value */
typedef uint32_t        gid_t;

#if TARGET_OS_IPHONE
typedef UIEvent         KTEvent;
typedef UITouch         KTTouch;
typedef UIView          KTCocoaView;
typedef UIWindow        KTCocoaWindow;
typedef UIResponder		KKResponder;
typedef UIApplication   KTApplication;

#else
typedef NSEvent         KTEvent;
typedef NSTouch         KTTouch;
typedef NSView          KTCocoaView;
typedef NSWindow        KTCocoaWindow;
typedef NSResponder		KKResponder;
typedef NSApplication   KTApplication;
#endif // TARGET_OS_MAC


