/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


/** This header includes all the most commonly needed headers within the framework and 
 typedefs SK classes that haven't been subclassed yet for forward compatibility. */

#import <Availability.h>
#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "KKCategories.h"
#import "KKMacros.h"
#import "KKTypes.h"
#import "KKVersion.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

typedef UIResponder KKResponder;
typedef UITouch KKTouch;
typedef UIWindow KKWindow;
#else
#import <Cocoa/Cocoa.h>

typedef NSResponder KKResponder;
typedef NSTouch KKTouch;
typedef NSWindow KKWindow;

#define NSStringFromCGRect NSStringFromRect
#define NSStringFromCGPoint NSStringFromPoint
#endif

/** typedefs for SK forward compatibility */
typedef SKTransition KKTransition;
typedef SKAction KKAction;

typedef SKTexture KKTexture;
typedef SKTextureAtlas KKTextureAtlas;

typedef SKCropNode KKCropNode;
typedef SKEffectNode KKEffectNode;
typedef SKKeyframeSequence KKKeyframeSequence;
typedef SKShapeNode KKShapeNode;
typedef SKVideoNode KKVideoNode;

typedef SKPhysicsContact KKPhysicsContact;
typedef SKPhysicsJoint KKPhysicsJoint;
typedef SKPhysicsJointFixed KKPhysicsJointFixed;
typedef SKPhysicsJointLimit KKPhysicsJointLimit;
typedef SKPhysicsJointPin KKPhysicsJointPin;
typedef SKPhysicsJointSliding KKPhysicsJointSliding;
typedef SKPhysicsJointSpring KKPhysicsJointSpring;
typedef SKPhysicsWorld KKPhysicsWorld;
