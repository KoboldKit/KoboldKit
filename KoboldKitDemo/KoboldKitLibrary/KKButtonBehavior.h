//
//  KKButtonBehavior.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"

@class KKButtonBehavior;

extern NSString* const KKButtonDidExecute;
typedef void (^KKButtonExecuteBlock)(KKButtonBehavior* buttonBehavior);

@interface KKButtonBehavior : KKBehavior
{
	@private
	CGFloat _originalXScale;
	CGFloat _originalYScale;
}

@property (atomic) CGFloat focusScale;
@property (atomic) BOOL hasFocus;

+(id) buttonWithBlock:(KKButtonExecuteBlock)executeBlock;

-(void) gainFocus;
-(void) loseFocus;
-(void) execute;

@end
