//
//  KKButtonBehavior.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKNodeBehavior.h"

@class KKButtonBehavior;

/** Notification name, sent by KKButtonBehavior when button should execute its action. */
extern NSString* const KKButtonDidExecute;

/** KKButtonBehavior turns any node into a button. Touch/Click on the node while be detected, the node is scaled while selected.
 Scaling is optional and can be modified/disabled with the selectedScale property.
 
 If a touch/click started and then ended on the node, a notification with name `KKButtonDidExecute` is posted to the
 [NSNotificationCenter](https://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/nsnotificationcenter_Class/Reference/Reference.html) 
 with the button behavior's node as sender.
 
 To register to receive the button notifications:
 
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(buttonDidExecute:)
			   name:KKButtonDidExecute
			 object:buttonNode];
 
 The observer is usually `self` but can be any other object implementing the selector.
 The selector can have any name.
 The object parameter should be the node with the KKButtonBehavior. You can also send `nil` as object, this will make
 the selector receive KKButtonDidExecute notifications from all nodes with a KKButtonBehavior.
 
 The selector implementation takes one argument of type NSNotification:
 
	-(void) buttonDidExecute:(NSNotification*)note
	{
		// notification.object is the sending node:
		SKNode* sender = note.object;
 
		// behavior is obtainable via userInfo dictionary:
		KKButtonBehavior* behavior = [note.userInfo objectForKey:@"behavior"];
	} 
 
 Note: an NSNotification is sent because using blocks or target/selector would prevent the class from being NSCopying/NSCoding compliant.
 Blocks and target/selector can not be copied or archived. */
@interface KKButtonBehavior : KKNodeBehavior
{
	@private
	CGFloat _originalXScale;
	CGFloat _originalYScale;
}

/** @name Selection Properties */

/** Determines the amount of scale when the button is selected. Default is 1.1 (slightly enlarged). A value of 1.0 will disable scaling altogether.
 @returns The current focus scale. */
@property (atomic) CGFloat selectedScale;
/** @returns YES if the button is currently selected. */
@property (atomic, readonly) BOOL isSelected;

/** @name Select & Execute Methods */

/** Will make the node enter the selected state. This is normally used internally, but you may want to use this to highlight buttons,
 for example in a tutorial. You can also override the method in a subclass to perform your own selection style, perhaps changing texture or color. */
-(void) beginSelect;
/** Will make the node exit the selected state. This is normally used internally, but may be helpful for tutorials (see beginSelect). 
 You can override the method in a subclass to perform your own deselection style. */
-(void) endSelect;
/** Will make the button post the KKButtonDidExecute notification. Calling this method will simulate a button press action.
 You can override the method in a subclass to either handle the execute directly. To ensure the notification is posted, call `[super execute]`
 in your implementation. */
-(void) execute;

@end
