/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKBehavior.h"

@class KKButtonBehavior;

/** Notification name, sent by KKButtonBehavior when button should execute its action. */
extern NSString* const KKButtonDidExecuteNotification;
/** Notification name, sent by KKButtonBehavior when continuous button stops executing its action. */
extern NSString* const KKButtonDidEndExecuteNotification;

/** KKButtonBehavior turns any node into a button. Touch/Click on the node while be detected, the node is scaled while selected.
 Scaling is optional and can be modified/disabled with the selectedScale property.
 
 If a touch/click started and then ended on the node, a notification with name `KKButtonDidExecuteNotification` is posted to the
 [NSNotificationCenter](https://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/nsnotificationcenter_Class/Reference/Reference.html) 
 with the button behavior's node as sender.
 
 To register to receive the button notifications:
 
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(buttonDidExecute:)
			   name:KKButtonDidExecuteNotification
			 object:buttonNode];
 
 The observer is usually `self` but can be any other object implementing the selector.
 The selector can have any name.
 The object parameter should be the node containing the KKButtonBehavior instance, or nil. If you use `nil` as object,
 the selector receives all KKButtonDidExecuteNotification notifications from all KKButtonBehaviors.
 
 The selector implementation takes one argument of type NSNotification:
 
	-(void) buttonDidExecute:(NSNotification*)note
	{
		// object is the sending node:
		SKNode* node = note.object;
 
		// get the behavior
		KKButtonBehavior* buttonBehavior = [node behaviorForKey:@"theKey"];
	}
 
 Note: an NSNotification is sent because using blocks or target/selector would prevent the class from being NSCopying/NSCoding compliant.
 Blocks and target/selector can not be copied or archived. */
@interface KKButtonBehavior : KKBehavior <KKSceneEventDelegate>
{
	@private
	CGFloat _originalXScale;
	CGFloat _originalYScale;
	
	SKTexture* _originalTexture;
	NSUInteger _trackedTouch;
	
	BOOL _continuous;
}

/** @name Selection Properties */

/** Set the selected texture if you want this to be exchanged with the sprite's texture during selection. Only works with SKSpriteNode nodes. */
@property (atomic) SKTexture* selectedTexture;
/** Determines the amount of scale when the button is selected. Default is 1.1 (slightly enlarged). A value of 1.0 will disable scaling altogether.
 @returns The current focus scale. */
@property (atomic) CGFloat selectedScale;
/** @returns YES if the button is currently selected. */
@property (atomic, readonly) BOOL selected;
/** If enabled, the button will send the execute notification when it is pressed. The default will send the notification when the button is released.
 @returns YES if the button will execute when pressed. NO if the button will execute when released. */
@property (atomic) BOOL executesWhenPressed;
/** If enabled, the button will send the execute notification continuously as long as it is pressed. It will also send the "released" notification
 when it is no longer pressed.
 @returns YES if the button will execute continously while pressed. */
@property (atomic) BOOL continuous;


/** @name Select & Execute Methods */

/** Will make the node enter the selected state. This is normally used internally, but you may want to use this to highlight buttons,
 for example in a tutorial. You can also override the method in a subclass to perform your own selection style, perhaps changing texture or color. */
-(void) beginSelect;
/** Will make the node exit the selected state. This is normally used internally, but may be helpful for tutorials (see beginSelect). 
 You can override the method in a subclass to perform your own deselection style. */
-(void) endSelect;
/** Will make the button post the KKButtonDidExecute notification. Calling this method will simulate a button press action.
 You can override the method in a subclass to either handle the execute directly. To ensure the notification is posted, call [super execute]
 in your implementation. */
-(void) execute;

@end
