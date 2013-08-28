//
//  KKToolHelper.h
//  KKNewProject
//
//  Created by Steffen Itterheim on 27.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKToolHelper : NSObject

+(NSString*) pathToKoboldKit;

/** Displays alert window if error is non-nil. */
+(void) alertWithError:(NSError*)error;

+(NSString*) appSupportDirectory;

@end
