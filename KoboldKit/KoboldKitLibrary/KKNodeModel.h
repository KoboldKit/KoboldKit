//
//  KKNodeModel.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 14.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KKNodeController;

@interface KKNodeModel : NSObject <NSCoding, NSCopying>
{
	@private
	NSMutableDictionary* _keyedValues;
}

/** @returns The model's controller object. You should never change this reference yourself! */
@property (nonatomic, weak) KKNodeController* controller;

@end
