//
//  SKColor+KoboldKit.m
//  KoboldKit
//
//  Created by Sam Green on 12/20/13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "SKColor+KoboldKit.h"

@implementation SKColor (KoboldKit)

+ (SKColor *)randomColor {
    return [SKColor randomColorWithAlpha:1.f];
}

+ (SKColor *)randomColorWithAlpha:(CGFloat)alpha {
    return [SKColor colorWithRed:KKRANDOM_0_1() green:KKRANDOM_0_1() blue:KKRANDOM_0_1() alpha:alpha];
}

@end
