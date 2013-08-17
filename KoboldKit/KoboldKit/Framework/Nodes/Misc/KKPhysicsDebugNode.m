//
//  KKPhysicsShapeNode.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 27.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKCompatibility.h"
#import "KKPhysicsDebugNode.h"
#import "SKNode+KoboldKit.h"

@implementation KKPhysicsDebugNode

-(id) init
{
	self = [super init];
	if (self)
	{
		_contacts = [NSMutableArray arrayWithCapacity:16];
	}
	return self;
}

-(void) didMoveToParent
{
	[self observeSceneEvents];
}

-(void) addContact:(SKPhysicsContact*)contact
{
	[_contacts addObject:contact];
}

-(void) removeContact:(SKPhysicsContact*)contact
{
	NSUInteger i = _contacts.count;
	[_contacts removeObject:contact];
	LOG_EXPR(i != _contacts.count);
}

-(void) removeAllContacts
{
	[_contacts removeAllObjects];
}

-(void) didSimulatePhysics
{
	if (_contactNode == nil)
	{
		_contactNode = [SKNode node];
		[self addChild:_contactNode];
	}
	else
	{
		[_contactNode removeAllChildren];
	}
	
	for (SKPhysicsContact* contact in _contacts)
	{
		CGPoint posA = contact.bodyA.node.position;
		CGPoint contactPos = contact.contactPoint;
		CGPoint posB = contact.bodyB.node.position;
		
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, nil, posA.x, posA.y);
		CGPathAddLineToPoint(path, nil, contactPos.x, contactPos.y);
		CGPathAddLineToPoint(path, nil, posB.x, posB.y);
		
		SKShapeNode* shapeNode = [SKShapeNode node];
		shapeNode.path = path;
		CGPathRelease(path);

		shapeNode.lineWidth = 1.0;
		shapeNode.antialiased = NO;
		shapeNode.strokeColor = [SKColor greenColor];
		[_contactNode addChild:shapeNode];
	}
}

@end
