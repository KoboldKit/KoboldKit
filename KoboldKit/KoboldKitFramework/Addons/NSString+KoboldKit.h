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

/** @returns String converted to SKColor object. The string must be in the form "1.0 1.0 1.0 1.0" where the
 values stand for the RGBA color values in the same order. */
-(SKColor*) color;

/** Performs a case sensitive search for a substring. Returns YES if the string contains the substring.
 @param subString The sub string to search for.
 @returns YES if the subString is contained in the string. */
-(BOOL) containsString:(NSString*)subString;

@end
