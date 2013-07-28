//
//  NSString+KoboldKit.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 28.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

/** NSString category methods */
@interface NSString (KoboldKit)

/** @returns A CGRect converted from a string rect representation like "{{10, 20}, {300, 400}}". */
-(CGRect) rectValue;
/** @returns A CGSize converted from a string size representation like "{10, 20}". */
-(CGSize) sizeValue;
/** @returns A CGPoint converted from a string point representation like "{300, 400}". */
-(CGPoint) pointValue;

@end
