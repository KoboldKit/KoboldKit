//
// EscapableTextField.m
// IMLocation
//
// Created by Vincent Gable on 10/2/07.
// Copyright 2007 Vincent Gable. All rights reserved.
//

#import "EscapableTextField.h"


@implementation EscapableTextField

-(void) cancelOperation:(id)sender
{
	if ([[self delegate] respondsToSelector:@selector(cancelOperation:)])
	{
		[[self delegate] cancelOperation:self];
	}
}

@end
