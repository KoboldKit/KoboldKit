//
//  KKInputKeyboard.h
//  KoboldKit
//
//  Created by Sam Green on 12/20/13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"

@interface KKInputKeyboard : KKBehavior

- (void)bindKey:(NSString *)key toAction:(NSString *)action;
- (void)unbindKey:(NSString *)key;

@end
