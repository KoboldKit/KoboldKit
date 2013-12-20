//
//  KKInputKeyboard.h
//  KoboldKit
//
//  Created by Sam Green on 12/20/13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"

@interface KKInputKeyboardBehavior : KKBehavior <KKSceneEventDelegate, KKInputEventDelegate>

// Bind a key to an action
- (void)bindKey:(NSString *)key toAction:(NSString *)action;
// Unbind a key
- (void)unbindKey:(NSString *)key;

// Key is currently down
- (BOOL)keyState:(NSString *)action;
// Key pressed this frame
- (BOOL)keyPressed:(NSString *)action;
// Key released this frame
- (BOOL)keyReleased:(NSString *)action;

@end
