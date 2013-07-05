//
//  MenuScene.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 04.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "MenuScene.h"
#import "GameScene.h"

@implementation MenuScene

static NSString* kAppSupportFolder = @"KoboldKitDemo";

-(void) didMoveToView:(SKView *)view
{
	[self addPleaseWaitLabel];
	
	// Enter IP address and port of the webserver running on your local developer machine.
	// Note: devices must be connected via Wifi to the same subnet as your dev machine,
	// and if the dev machine is running a firewall the port must be open.
	[self.kkView.model setObject:[NSURL URLWithString:@"http://10.0.0.8:31013"] forKey:KKDownloadProjectFilesURL];
	[self.kkView.model setObject:kAppSupportFolder forKey:KKDownloadProjectFilesAppSupportFolder];
	
	// Transfers all changed resource files from the remote server to the specified folder in the app support directory
	[KKDownloadProjectFiles downloadProjectFilesWithModel:self.kkView.model
										  completionBlock:^(NSDictionary *contents) {
											[self didDownloadProjectFiles:contents];
										}];
}

-(void) addPleaseWaitLabel
{
	self.backgroundColor = [SKColor colorWithHue:0.6 saturation:1.1 brightness:0.8 alpha:0.4];
	
	_pleaseWait = [KKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
	_pleaseWait.text = @"Downloading Resources ...";
	_pleaseWait.position = CGPointMake(self.size.width / 2, self.size.height / 2);
	[self addChild:_pleaseWait];
	
	SKAction* sequence = [SKAction sequence:@[[SKAction scaleXTo:0.9 duration:0.1], [SKAction scaleXTo:1.0 duration:0.2]]];
	[_pleaseWait runAction:[SKAction repeatActionForever:sequence]];
}

-(void) didDownloadProjectFiles:(NSDictionary*)projectFiles
{
	[_pleaseWait removeAllActions];
	[_pleaseWait runAction:[SKAction sequence:@[[SKAction moveToY:-_pleaseWait.fontSize duration:0.3], [SKAction removeFromParent]]]];
	_pleaseWait = nil;

	if (projectFiles)
	{
		CGFloat height = 0;
		_tmxLoadMenu = [SKNode node];
		[self addChild:_tmxLoadMenu];
		
		for (NSURL* key in projectFiles)
		{
			NSArray* files = [projectFiles objectForKey:key];
			for (NSString* file in files)
			{
				if ([[file lowercaseString] hasSuffix:@".tmx"])
				{
					KKLabelNode* tmxLabel = [KKLabelNode labelNodeWithFontNamed:@"Courier"];
					tmxLabel.fontSize = 28;
					tmxLabel.text = file;
					tmxLabel.position = CGPointMake(0, height);
					[_tmxLoadMenu addChild:tmxLabel];
					
					KKButtonBehavior* button = [KKButtonBehavior behavior];
					[tmxLabel addBehavior:button];
					[self observeNotification:KKButtonDidExecuteNotification selector:@selector(tmxButtonPressed:) object:tmxLabel];
					
					height -= tmxLabel.fontSize + 12;
				}
			}
		}
		
		_tmxLoadMenu.position = CGPointMake(self.size.width / 2, self.size.height + -height);
		[_tmxLoadMenu runAction:[SKAction moveToY:self.size.height - 80 duration:0.3]];
	}
}

-(void) tmxButtonPressed:(NSNotification*)notification
{
	GameScene* gameScene = [GameScene sceneWithSize:self.size];
	gameScene.tmxFile = [NSString stringWithFormat:@"%@/%@", kAppSupportFolder, ((KKLabelNode*)notification.object).text];
	[self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[SKColor grayColor] duration:0.5]];
}

@end
