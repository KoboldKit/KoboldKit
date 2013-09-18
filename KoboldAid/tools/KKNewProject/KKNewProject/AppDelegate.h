//
//  AppDelegate.h
//  KKNewProject
//
//  Created by Steffen Itterheim on 27.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate, NSTableViewDelegate>
{
	KKXcodeProjectsTableViewDataSource* _projects;
	NSMutableArray* _createdProjectLocations;
}

@property (assign) IBOutlet NSWindow *window;
@property (readonly) NSString* pathToKoboldKitRoot;
@property (weak) IBOutlet NSTableView *projectsView;
@property (weak) IBOutlet NSTextField *descriptionField;
@property (weak) IBOutlet NSTextField *directoryField;
@property (weak) IBOutlet NSTextField *projectNameField;
@property (weak) IBOutlet NSTextField *projectPathLabel;
- (IBAction)createButtonClicked:(id)sender;
- (IBAction)browseDirectory:(id)sender;

@end
