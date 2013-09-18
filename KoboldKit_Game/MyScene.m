/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "MyScene.h"
#import "RemoveSpaceshipBehavior.h"

@implementation MyScene

-(id) initWithSize:(CGSize)size
{
	self = [super initWithSize:size];
	if (self)
	{
		/* Setup your scene here */
		self.backgroundColor = [SKColor colorWithRed:0.4 green:0.0 blue:0.4 alpha:1.0];
		
		SKLabelNode* myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
		myLabel.text = @"Hello, Kobold!";
		myLabel.fontSize = 60;
		myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
		[self addChild:myLabel];

		[self addSmartbombButton];
	}
	return self;
}

-(void) addSmartbombButton
{
	// label will become a button that removes all spaceships
	SKLabelNode* buttonLabel = [SKLabelNode labelNodeWithFontNamed:@"Monaco"];
	buttonLabel.text = @"SMARTBOMB!";
	buttonLabel.fontSize = 32;
	buttonLabel.zPosition = 1;
	buttonLabel.position = CGPointMake(CGRectGetMidX(self.frame),
									   self.frame.size.height - buttonLabel.frame.size.height);
	[self addChild:buttonLabel];
	
	// KKButtonBehavior turns any node into a button
	KKButtonBehavior* buttonBehavior = [KKButtonBehavior behavior];
	buttonBehavior.selectedScale = 1.2;
	[buttonLabel addBehavior:buttonBehavior];
	
	// observe button execute notification
	[self observeNotification:KKButtonDidExecuteNotification
					 selector:@selector(clearSpaceButtonDidExecute:)
					   object:buttonLabel];

	// preload the sound the button plays
	[[OALSimpleAudio sharedInstance] preloadEffect:@"die.wav"];
}

-(void) clearSpaceButtonDidExecute:(NSNotification*)notification
{
	[[OALSimpleAudio sharedInstance] playEffect:@"die.wav"];

	[self enumerateChildNodesWithName:@"spaceship" usingBlock:^(SKNode* node, BOOL* stop) {
		// enable physics, makes spaceships drop (they will be removed by the custom behavior)
		CGFloat radius = node.frame.size.width / 4.0;
		node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
	}];
}

-(void) addSpaceshipAt:(CGPoint)location
{
	SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
	sprite.position = location;
	sprite.name = @"spaceship";
	[sprite setScale:0.5];
	[self addChild:sprite];
	
	SKAction* action = [SKAction rotateByAngle:M_PI duration:1];
	[sprite runAction:[SKAction repeatActionForever:action]];

	// this behavior will remove the node if node's position.y falls below the removeHeight
	RemoveSpaceshipBehavior* removeBehavior = [RemoveSpaceshipBehavior new];
	removeBehavior.removeHeight = -sprite.frame.size.height;
	[sprite addBehavior:removeBehavior];
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
