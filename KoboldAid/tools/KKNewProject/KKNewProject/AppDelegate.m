//
//  AppDelegate.m
//  KKNewProject
//
//  Created by Steffen Itterheim on 27.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "AppDelegate.h"
#import "KKToolHelper.h"
#import "KKXcodeProject.h"

@implementation AppDelegate

-(void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"======================================================================================\nKKNewProject launching...");
	
	// always operate with the app's path (ie when running from Xcode working dir will be in DerivedData)
	NSString* pathToKoboldKit = [KKToolHelper pathToKoboldKit];

	// must set the working directory to the same as where the app resides, so that relative paths work as expected
	NSFileManager* fileManager = [NSFileManager defaultManager];
	[fileManager changeCurrentDirectoryPath:pathToKoboldKit];

	_projects = [KKXcodeProject xcodeProjectsAtPath:pathToKoboldKit];
	
	// create list of copy-able projects
	_projectsView.dataSource = _projects;
	[_projectsView reloadData];

	// load defaults
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	_createdProjectLocations = [NSMutableArray arrayWithArray:[defaults stringArrayForKey:KKUserDefaultsProjectLocations]];
	if (_createdProjectLocations == nil)
	{
		_createdProjectLocations = [NSMutableArray array];
	}
	LOG_EXPR(_createdProjectLocations);

	NSString* lastPath = [defaults stringForKey:KKUserDefaultsNewProjectLastPath];
	if (lastPath.length)
	{
		_directoryField.stringValue = lastPath;
	}
	
	NSString* lastName = [defaults stringForKey:KKUserDefaultsNewProjectLastName];
	if (lastName.length)
	{
		_projectNameField.stringValue = lastName;
	}

	[self updateDescription];
	[self updateProjectPathLabel];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) tableViewSelectionDidChange:(NSNotification*)aNotification
{
	[self updateDescription];
}

-(void) controlTextDidChange:(NSNotification *)aNotification
{
	NSTextField* textField = aNotification.object;
	if (textField.tag == 1)
	{
		[self updateProjectPathLabel];
	}
}

-(void) updateUserDefaults
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:_createdProjectLocations forKey:KKUserDefaultsProjectLocations];
	[defaults setObject:_directoryField.stringValue forKey:KKUserDefaultsNewProjectLastPath];
	[defaults setObject:_projectNameField.stringValue forKey:KKUserDefaultsNewProjectLastName];
}

-(void) updateDescription
{
	KKXcodeProject* project = [self selectedProject];
	_descriptionField.stringValue = project.description;
}

-(void) updateProjectPathLabel
{
	KKXcodeProject* project = [self selectedProject];
	NSString* path = [project projectPathWithDirectory:_directoryField.stringValue
										   projectName:_projectNameField.stringValue];
	if (path)
	{
		_projectPathLabel.stringValue = path;
		
		[self updateUserDefaults];
	}
}

-(NSString*) selectedProjectName
{
	NSString* selectedProjectName = nil;
	if (_projectsView.selectedRow < _projects.array.count)
	{
		NSString* name = [_projects.array objectAtIndex:_projectsView.selectedRow];
		if (name.length)
		{
			selectedProjectName = name;
		}
	}
	return selectedProjectName;
}

-(KKXcodeProject*) selectedProject
{
	NSString* selectedProjectName = [self selectedProjectName];
	if (selectedProjectName)
	{
		return [_projects.dictionary objectForKey:selectedProjectName];
	}
	
	return nil;
}

-(IBAction) browseDirectory:(id)sender
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.canChooseFiles = NO;
	openPanel.canChooseDirectories = YES;
	openPanel.allowsMultipleSelection = NO;
	openPanel.canCreateDirectories = YES;
	
	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
	 {
		 if (result != 0)
		 {
			 NSLog(@"result: %i, selected: %@", (int)result, openPanel.URL);
			 _directoryField.stringValue = [[openPanel.URL path] stringByStandardizingPath];
		 }
	 }];
	
	[self updateProjectPathLabel];
}

-(IBAction) createButtonClicked:(id)sender
{
	KKXcodeProject* project = [self selectedProject];
	NSString* directory = _directoryField.stringValue;
	NSString* newName = _projectNameField.stringValue;
	
	if (project && directory.length && newName.length)
	{
		NSError* error;
		if ([project copyToDirectory:directory name:newName error:&error])
		{
			// add the project path
			NSString* projectPath = [project projectPathWithDirectory:directory projectName:newName];
			[_createdProjectLocations addObject:[projectPath stringByDeletingLastPathComponent]];
			
			[self updateUserDefaults];

			// open new project in xcode
			[[NSWorkspace sharedWorkspace] openFile:projectPath];
		}
		else
		{
			[KKToolHelper alertWithError:error];
		}
	}
	else
	{
		NSError* error = [NSError errorWithDomain:@"Project name or directory path: empty string" code:0 userInfo:nil];
		NSAlert* alert = [NSAlert alertWithError:error];
		[alert runModal];
	}
}

@end
