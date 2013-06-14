//
//  KKViewController.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKViewController.h"
#import "SKNode+KoboldKit.h"
#import "JRSwizzle.h"

@interface KKViewController ()

@end

@implementation KKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self swizzleMethods];
	
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
}

-(void) checkSwizzleError:(NSError*)error
{
	NSAssert1(error == nil, @"Method swizzling error: %@", error);
}

-(void) swizzleDescriptionForNodeClass:(Class)nodeClass
{
	NSError* error;
	[nodeClass jr_swizzleMethod:@selector(description) withMethod:@selector(kkDescription) error:&error];
	[self checkSwizzleError:error];
}

-(void) swizzleMethods
{
	// swizzle some methods to hook into Sprite Kit
	NSError* error;
	
	[self swizzleDescriptionForNodeClass:[SKNode class]];
	[self swizzleDescriptionForNodeClass:[SKScene class]];
	[self swizzleDescriptionForNodeClass:[SKCropNode class]];
	[self swizzleDescriptionForNodeClass:[SKEffectNode class]];
	[self swizzleDescriptionForNodeClass:[SKEmitterNode class]];
	[self swizzleDescriptionForNodeClass:[SKLabelNode class]];
	[self swizzleDescriptionForNodeClass:[SKShapeNode class]];
	[self swizzleDescriptionForNodeClass:[SKSpriteNode class]];
	[self swizzleDescriptionForNodeClass:[SKVideoNode class]];

	[SKNode jr_swizzleMethod:@selector(copyWithZone:)
				  withMethod:@selector(kkCopyWithZone:) error:&error];
	[self checkSwizzleError:error];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@dynamic kkView;
-(KKView*) kkView
{
	return (KKView*)self.view;
}

@end
