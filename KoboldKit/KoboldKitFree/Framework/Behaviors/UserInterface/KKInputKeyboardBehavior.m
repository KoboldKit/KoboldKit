//
//  KKInputKeyboard.m
//  KoboldKit
//
//  Created by Sam Green on 12/20/13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKInputKeyboardBehavior.h"

@interface KKInputKeyboardBehavior ()

@property (nonatomic, strong) NSMutableDictionary *bindings;
@property (nonatomic, strong) NSMutableDictionary *states;
@property (nonatomic, strong) NSMutableDictionary *pressed;
@property (nonatomic, strong) NSMutableDictionary *locked;
@property (nonatomic, strong) NSMutableDictionary *delayedKeyUp;

@property (nonatomic, strong) NSDictionary *keyCodeForString;

@end

@implementation KKInputKeyboardBehavior

- (id)init {
    self = [super init];
    if (self) {
        self.delayedKeyUp = [NSMutableDictionary dictionary];
        self.bindings = [NSMutableDictionary dictionary];
        self.pressed = [NSMutableDictionary dictionary];
        self.states = [NSMutableDictionary dictionary];
        self.locked = [NSMutableDictionary dictionary];
        
        self.keyCodeForString = @{ @"enter": @"\r" };
    }
    return self;
}

#pragma mark - Behavior Events
- (void)didJoinController {
    [self.node.kkScene addInputEventsObserver:self];
    [self.node.kkScene addSceneEventsObserver:self];
}

- (void)didLeaveController {
    [self.node.kkScene removeInputEventsObserver:self];
    [self.node.kkScene removeSceneEventsObserver:self];
}

#pragma mark - KKSceneEventDelegate
- (void)didSimulatePhysics {
    [self clearPressed];
}

#pragma mark - KKInputEventDelegate
- (void)keyDown:(NSEvent *)theEvent {
    [self handleKeyEvent:theEvent keyDown:YES];
}

- (void)keyUp:(NSEvent *)theEvent {
    [self handleKeyEvent:theEvent keyDown:NO];
}

#pragma mark - Public Methods
- (void)bindKey:(NSString *)key toAction:(NSString *)action {
    [self toggleKeyBinding:key forAction:action enabled:YES];
}

- (void)unbindKey:(NSString *)key {
    [self toggleKeyBinding:key forAction:nil enabled:NO];
}

- (BOOL)keyState:(NSString *)action {
    return [self.states[action] boolValue];
}

- (BOOL)keyPressed:(NSString *)action {
    return [self.pressed[action] boolValue];
}

- (BOOL)keyReleased:(NSString *)action {
    return [self.delayedKeyUp[action] boolValue];
}

#pragma mark - Private Methods
- (void)toggleKeyBinding:(NSString *)key forAction:(NSString *)action enabled:(BOOL)enabled {
    // Convenience Binding aliases
    NSString *matchedKey = [self keyForCode:key];
    if (matchedKey) {
        key = matchedKey;
    }
    
    if (enabled) {
        self.bindings[key] = action;
    } else {
        NSString *keyAction = self.bindings[key];
        self.delayedKeyUp[keyAction] = @YES;
        [self.bindings removeObjectForKey:key];
    }
}

#pragma mark Input Helper
- (void)handleKeyEvent:(NSEvent *)event keyDown:(BOOL)isDown {
    NSString *characters = [event characters];
    for (NSUInteger s = 0; s < [characters length]; s++) {
        
        NSString *character = [characters substringWithRange:NSMakeRange(s, 1)];
        NSString *action = self.bindings[character];
        if (action == nil) continue;
        
        if (isDown) {
            self.states[action] = @YES;
            
            if (![self.locked[action] boolValue]) {
                self.locked[action] = @YES;
                self.pressed[action] = @YES;
            }
        } else {
            // Set the delayed key up flag so we'll have a released action
            self.delayedKeyUp[action] = @YES;
        }
    }
}

- (void)clearPressed {
    // Reset all actions and locks
    for (NSString *action in self.delayedKeyUp.allKeys) {
        self.states[action] = @NO;
        self.locked[action]= @NO;
    }
    
    // Clean up presses and delayedKeyUp
    [self.delayedKeyUp removeAllObjects];
    [self.pressed removeAllObjects];
}

- (NSString *)keyForCode:(NSString *)escapeCode {
    return self.keyCodeForString[escapeCode];
}

@end
