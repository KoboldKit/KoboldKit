/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "MyScene.h"

@implementation MyScene

-(id) initWithSize:(CGSize)size
{
	self = [super initWithSize:size];
	if (self)
	{
		/* Setup your scene here */
		self.backgroundColor = [SKColor colorWithRed:0.2 green:0.0 blue:0.2 alpha:1.0];
		
		KKLabelNode* myLabel = [KKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
		myLabel.text = @"Hello, Kobold!";
		myLabel.fontSize = 60;
		myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
									   CGRectGetMidY(self.frame));
		[self addChild:myLabel];

		[self addClearSpaceButton];
	}
	return self;
}

-(void) addClearSpaceButton
{
	// label will become a button to remove all spaceships
	KKLabelNode* removeLabel = [KKLabelNode labelNodeWithFontNamed:@"Monaco"];
	removeLabel.text = @"Clear Space!";
	removeLabel.fontSize = 32;
	removeLabel.zPosition = 1;
	removeLabel.position = CGPointMake(CGRectGetMidX(self.frame),
									   self.frame.size.height - removeLabel.frame.size.height);
	[self addChild:removeLabel];
	
	// KKButtonBehavior turns any node into a button
	KKButtonBehavior* buttonBehavior = [KKButtonBehavior behavior];
	buttonBehavior.selectedScale = 1.2;
	[removeLabel addBehavior:buttonBehavior];
	
	// observe button execute notification
	[self observeNotification:KKButtonDidExecuteNotification
					 selector:@selector(clearSpaceButtonDidExecute:)
					   object:removeLabel];
}

-(void) clearSpaceButtonDidExecute:(NSNotification*)notification
{
	[self enumerateChildNodesWithName:@"spaceship" usingBlock:^(SKNode* node, BOOL* stop) {
		[node removeFromParent];
	}];
}

-(void) addSpaceshipAt:(CGPoint)location
{
	KKSpriteNode* sprite = [KKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
	sprite.position = location;
	sprite.name = @"spaceship";
	[sprite setScale:0.5];
	[self addChild:sprite];
	
	KKAction* action = [KKAction rotateByAngle:M_PI duration:1];
	[sprite runAction:[KKAction repeatActionForever:action]];
}

#if TARGET_OS_IPHONE // iOS
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	/* Called when a touch begins */
	
	for (UITouch* touch in touches)
	{
		CGPoint location = [touch locationInNode:self];
		[self addSpaceshipAt:location];
	}
	
	// (optional) call super implementation to allow KKScene to dispatch touch events
	[super touchesBegan:touches withEvent:event];
}
#else // Mac OS X
-(void) mouseDown:(NSEvent *)event
{
	/* Called when a mouse click occurs */
	
	CGPoint location = [event locationInNode:self];
	[self addSpaceshipAt:location];

	// (optional) call super implementation to allow KKScene to dispatch mouse events
	[super mouseDown:event];
}
#endif

-(void) update:(CFTimeInterval)currentTime
{
	/* Called before each frame is rendered */
	
	// (optional) call super implementation to allow KKScene to dispatch update events
	[super update:currentTime];
}

@end
