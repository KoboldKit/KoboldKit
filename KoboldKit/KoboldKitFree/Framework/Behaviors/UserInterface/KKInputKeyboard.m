//
//  KKInputKeyboard.m
//  KoboldKit
//
//  Created by Sam Green on 12/20/13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKInputKeyboard.h"

@interface KKInputKeyboard ()

@property (nonatomic, strong) NSMutableDictionary *keyToAction;

@end

@implementation KKInputKeyboard

- (id)init {
    self = [super init];
    if (self) {
        self.keyToAction = [NSMutableDictionary dictionaryWithCapacity:5];
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

#pragma mark - Scene Events
- (void)update:(CFTimeInterval)update {
    
}

#pragma mark - Input Events
- (void)keyDown:(NSEvent *)event {
    
}

- (void)keyUp:(NSEvent *)event {
    
}

#pragma mark - Public Methods
- (void)bindKey:(NSString *)key toAction:(NSString *)action {
    
}

- (void)unbindKey:(NSString *)key {
    
}

@end
