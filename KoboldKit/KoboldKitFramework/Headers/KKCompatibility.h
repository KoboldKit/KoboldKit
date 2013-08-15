//
//  KKCompatibility.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 09.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//


/** This header includes all the most commonly needed headers and 
 typedefs SK classes that haven't been subclassed yet for forward compatibility. */


#ifndef KoboldKit_KKCompatibility_h
#define KoboldKit_KKCompatibility_h

#import <Availability.h>
#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import <objc/runtime.h>
#import "KKMacros.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

/** typedefs for platform compatibility */
#if TARGET_OS_IPHONE
typedef UIResponder KKResponder;
typedef UITouch KKTouch;
typedef UIWindow KKWindow;
#else
typedef NSResponder KKResponder;
typedef NSTouch KKTouch;
typedef NSWindow KKWindow;

#define NSStringFromCGRect NSStringFromRect
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

#endif
