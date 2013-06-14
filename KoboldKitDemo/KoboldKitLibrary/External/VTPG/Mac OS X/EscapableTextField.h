//
// EscapableTextField.h
// IMLocation
//
// Created by Vincent Gable on 10/2/07.
// Copyright 2007 Vincent Gable. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EscapableTextField : NSTextField {
}

// Requires 10.3
// This method will be called on esc, or cmd-. (period)
-(void) cancelOperation:(id)sender;

@end
