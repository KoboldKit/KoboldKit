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

-(void) didMoveToView:(SKView *)view
{
	[self addPleaseWaitLabel];
	
	// Transfers all changed resource files from the remote server to the app support directory.
	// Enter IP address and port of the webserver running on your local developer machine in devconfig.lua.
	// Note: devices must be connected via Wifi to the same subnet as your dev machine, and if the dev machine is running a firewall
	// or behind a router you may need to open ports or setup port forwarding.
	NSString* url = [self.kkView.model valueForKeyPath:@"devconfig.developmentWebServerURL"];
	[KKDownloadProjectFiles downloadProjectFilesWithURL:[NSURL URLWithString:url]
										  completionBlock:^(NSDictionary *contents) {
											  [self didDownloadProjectFiles:contents];
											  [self.kkView reloadConfig];
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
	[_pleaseWait removeFromParent];
	_pleaseWait = nil;

	if (projectFiles == nil)
	{
		NSMutableArray* files = [NSMutableArray arrayWithCapacity:8];
		NSString* path;

		// fallback to loading all TMX files already present
#if TARGET_OS_IPHONE
		// only scan the user's documents directory on iOS
		path = [NSFileManager pathToDocumentsDirectory];
		NSDirectoryEnumerator* documentsEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
		NSString* file;
		while (file = [documentsEnumerator nextObject])
		{
			if ([[[file lowercaseString] pathExtension] isEqualToString:@"tmx"])
			{
				[files addObject:[file lastPathComponent]];
			}
		}
#endif

		// no TMX files in documents? Get the bundled TMX files instead.
		if (files.count == 0)
		{
			path = [[NSBundle mainBundle] bundlePath];
			NSDirectoryEnumerator* documentsEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
			NSString* file;
			while (file = [documentsEnumerator nextObject])
			{
				if ([[[file lowercaseString] pathExtension] isEqualToString:@"tmx"])
				{
					[files addObject:[file lastPathComponent]];
				}
			}
		}
		
		projectFiles = [NSDictionary dictionaryWithObject:files forKey:[NSURL URLWithString:@"http://0.0.0.0"]];
	}
	
	if (projectFiles.count > 0)
	{
		_tmxLoadMenu = [SKNode node];
		[self addChild:_tmxLoadMenu];
		
		NSMutableArray* tmxFiles = [NSMutableArray arrayWithCapacity:4];
		for (NSURL* key in projectFiles)
		{
			NSArray* files = [projectFiles objectForKey:key];
			for (NSString* file in files)
			{
				if ([[file lowercaseString] hasSuffix:@".tmx"])
				{
					[tmxFiles addObject:file];
				}
			}
		}

		[tmxFiles sortUsingSelector:@selector(caseInsensitiveCompare:)];
		
		CGFloat height = 0;
		for (NSString* tmxFile in tmxFiles)
		{
			KKLabelNode* tmxLabel = [KKLabelNode labelNodeWithFontNamed:@"Courier"];
			tmxLabel.fontSize = 28;
			tmxLabel.text = tmxFile;
			tmxLabel.position = CGPointMake(0, height);
			[_tmxLoadMenu addChild:tmxLabel];
			
			KKButtonBehavior* button = [KKButtonBehavior behavior];
			[tmxLabel addBehavior:button];
			[self observeNotification:KKButtonDidExecuteNotification selector:@selector(tmxButtonPressed:) object:tmxLabel];
			
			height -= tmxLabel.fontSize + 2;
		}
		
		_tmxLoadMenu.position = CGPointMake(self.size.width / 2, self.size.height - 50);
		//_tmxLoadMenu.position = CGPointMake(self.size.width / 2, self.size.height + -height);
		//[_tmxLoadMenu runAction:[SKAction moveToY:self.size.height - 50 duration:0.3]];

		LOG_EXPR(_tmxLoadMenu.position);
		LOG_EXPR(self.size.height - 50);
	}
}

-(void) tmxButtonPressed:(NSNotification*)notification
{
	GameScene* gameScene = [GameScene sceneWithSize:self.size];
	gameScene.tmxFile = ((KKLabelNode*)notification.object).text;
	[self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[SKColor grayColor] duration:0.5]];
}

@end
