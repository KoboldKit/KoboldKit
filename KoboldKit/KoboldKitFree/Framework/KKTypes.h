/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


/** @file KKTypes.h */

/** gid (globally unique tile index) is an unsigned int (32 bit) value */
typedef uint32_t        gid_t;

#if TARGET_OS_IPHONE
typedef UIEvent         KKEvent;
typedef UITouch         KKTouch;
typedef UIView          KKCocoaView;
typedef UIWindow        KKCocoaWindow;
typedef UIResponder		KKResponder;
typedef UIApplication   KKApplication;
typedef EAGLContext		KKGLContext;

#else
typedef NSEvent         KKEvent;
typedef NSTouch         KKTouch;
typedef NSView          KKCocoaView;
typedef NSWindow        KKCocoaWindow;
typedef NSResponder		KKResponder;
typedef NSApplication   KKApplication;
typedef NSOpenGLContext	KKGLContext;
#endif // TARGET_OS_MAC
