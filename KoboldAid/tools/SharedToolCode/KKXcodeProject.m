//
//  KKXcodeProject.m
//  KKNewProject
//
//  Created by Steffen Itterheim on 27.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKXcodeProject.h"
#import "KKToolHelper.h"
#import "KKToolDataSource.h"
#import "KKCopyFilesFilter.h"

@implementation KKXcodeProject

+(KKXcodeProjectsTableViewDataSource*) xcodeProjectsAtPath:(NSString*)path
{
	KKXcodeProjectsTableViewDataSource* projects = [KKXcodeProjectsTableViewDataSource new];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSError* error;
	NSArray* contents = [fileManager contentsOfDirectoryAtPath:path error:&error];
	[KKToolHelper alertWithError:error];
	
	for (NSString* item in contents)
	{
		if ([item hasSuffix:@".xcodeproj"])
		{
			BOOL isDirectory = NO;
			NSString* projectPath = [NSString stringWithFormat:@"%@/%@", path, item];
			BOOL exists = [fileManager fileExistsAtPath:projectPath isDirectory:&isDirectory];
			if (exists && isDirectory)
			{
				KKXcodeProject* project = [KKXcodeProject xcodeProjectWithPath:projectPath];
				[projects setObject:project forKey:project.name];
			}
		}
	}
	
	return projects;
}

+(id) xcodeProjectWithPath:(NSString*)projectPath
{
	return [[self alloc] initWithPath:projectPath];
}

-(id) initWithPath:(NSString*)projectPath
{
	self = [super init];
	if (self)
	{
		_path = projectPath;
		_directory = [projectPath stringByDeletingLastPathComponent];
		_projectName = [projectPath lastPathComponent];
		_name = [[projectPath lastPathComponent] stringByDeletingPathExtension];
		NSLog(@"Xcode project: %@", _name);
		
		[self updateDescriptionFromFile];
	}
	return self;
}

-(void) updateDescriptionFromFile
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSArray* descriptionFiles = @[@"DESCRIPTION", @"DESCRIPTION.txt", @"README", @"README.txt", @"README.md"];
	_description = @"(no description available)";

	for (NSString* file in descriptionFiles)
	{
		NSString* path = [NSString stringWithFormat:@"%@/%@/%@", _directory, _name, file];
		if ([fileManager fileExistsAtPath:path])
		{
			NSString* fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
			if (fileContents.length)
			{
				_description = fileContents;
				break;
			}
		}
	}
}

-(NSString*) projectPathWithDirectory:(NSString*)directory projectName:(NSString*)projectName
{
	return [NSString stringWithFormat:@"%@/%@/%@.xcodeproj",
			[directory stringByStandardizingPath],
			[projectName stringByDeletingIllegalFileSystemCharacters],
			[projectName stringByDeletingIllegalXcodeCharacters]];
}

-(BOOL) copyToDirectory:(NSString*)directory name:(NSString*)name error:(NSError**)error
{
	NSString* projectPath = [self projectPathWithDirectory:directory projectName:name];
	NSString* newProjectName = [[projectPath lastPathComponent] stringByDeletingPathExtension];
	projectPath = [projectPath stringByDeletingLastPathComponent];
	
	LOG_EXPR(projectPath);
	LOG_EXPR(newProjectName);
	
	// verify input parameters
	if (directory.length == 0 || name.length == 0 || newProjectName.length == 0)
	{
		if (error)
		{
			NSString* message = @"directory or project name is an empty string";
			*error = [NSError errorWithDomain:message code:0 userInfo:nil];
		}
		return NO;
	}

	// verify that xcodeproj has a companion subfolder of the same name
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* sourceProjectFolderPath = [NSString stringWithFormat:@"%@/%@", _directory, _name];
	if ([fileManager fileExistsAtPath:sourceProjectFolderPath] == NO)
	{
		if (error)
		{
			NSString* message = [NSString stringWithFormat:@"the subfolder with the project's name is missing or its name is not identical:\n%@", sourceProjectFolderPath];
			*error = [NSError errorWithDomain:message code:0 userInfo:nil];
		}
		return NO;
	}
	
	// verify that no other project with the same name exists in target location
	BOOL directoryExists = [fileManager fileExistsAtPath:projectPath];
	if (directoryExists)
	{
		if (error)
		{
			NSString* message = [NSString stringWithFormat:@"destination directory already exists:\n%@", projectPath];
			*error = [NSError errorWithDomain:message code:0 userInfo:nil];
		}
		return NO;
	}
	
	// try to create the path which also checks for any permission errors
	NSError* internalError;
	if ([fileManager createDirectoryAtPath:projectPath withIntermediateDirectories:YES attributes:nil error:&internalError] == NO)
	{
		NSLog(@"%@", internalError);
		if (error)
		{
			NSString* message = [NSString stringWithFormat:@"failed to create destination directory:\n%@\n\nPossibly illegal path or permission error:\n%@", projectPath, internalError];
			*error = [NSError errorWithDomain:message code:0 userInfo:nil];
		}
		return NO;
	}
	
	// setup copy filter to skip copying certain files
	KKCopyFilesFilter* copyFilesFilter = [KKCopyFilesFilter new];
	copyFilesFilter.fileHasPrefixFilter = copyFilesFilter.directoryHasPrefixFilter = @[@"."]; // don't copy hidden files/folders (including .git .svn etc)
	//copyFilesFilter.logFilteredItems = YES;
	fileManager.delegate = copyFilesFilter;

	// copy project
	NSString* targetProjectPath = [NSString stringWithFormat:@"%@/%@.xcodeproj", projectPath, newProjectName];
	[fileManager copyItemAtPath:_path toPath:targetProjectPath error:&internalError];
	[KKToolHelper alertWithError:internalError];

	// copy project folder
	NSString* targetProjectFolderPath = [NSString stringWithFormat:@"%@/%@", projectPath, newProjectName];
	[fileManager copyItemAtPath:sourceProjectFolderPath toPath:targetProjectFolderPath error:&internalError];
	[KKToolHelper alertWithError:internalError];

	// copy kobold kit
	NSString* sourceKoboldKitPath = [NSString stringWithFormat:@"%@/KoboldKit", _directory];
	NSString* targetKoboldKitPath = [NSString stringWithFormat:@"%@/KoboldKit", projectPath];
	[fileManager copyItemAtPath:sourceKoboldKitPath toPath:targetKoboldKitPath error:&internalError];
	[KKToolHelper alertWithError:internalError];

	fileManager.delegate = nil;

	[self deleteUserDataFromProjectAtPath:projectPath projectFile:[NSString stringWithFormat:@"%@.xcodeproj", newProjectName]];
	[self deleteUserDataFromProjectAtPath:projectPath projectFile:@"KoboldKit/KoboldKitCommunity/KoboldKitCommunity.xcodeproj"];
	[self deleteUserDataFromProjectAtPath:projectPath projectFile:@"KoboldKit/KoboldKitExternal/KoboldKitExternal.xcodeproj"];
	[self deleteUserDataFromProjectAtPath:projectPath projectFile:@"KoboldKit/KoboldKitFree/KoboldKit.xcodeproj"];
	[self deleteUserDataFromProjectAtPath:projectPath projectFile:@"KoboldKit/KoboldKitPro/KoboldKitPro.xcodeproj"];

	// string replace in pbxproj
	NSString* pbxFile = [NSString stringWithFormat:@"%@/project.pbxproj", targetProjectPath];
	[NSString replaceOccurancesOfString:_name withString:newProjectName inFile:pbxFile encoding:NSUTF8StringEncoding];

	// string replace in workspacedata
	NSString* workspacePath = [NSString stringWithFormat:@"%@/project.xcworkspace", targetProjectPath];
	NSString* workspaceFile = [NSString stringWithFormat:@"%@/contents.xcworkspacedata", workspacePath];
	[NSString replaceOccurancesOfString:_name withString:newProjectName inFile:workspaceFile encoding:NSUTF8StringEncoding];

	// string replace in MainMenu.xib
	NSString* xibFile = [NSString stringWithFormat:@"%@/MainMenu.xib", targetProjectFolderPath];
	[NSString replaceOccurancesOfString:_name withString:newProjectName inFile:xibFile encoding:NSUTF8StringEncoding];

	// rename files: info.plist, prefix.pch
	NSString* infoPlistSuffix = @"Info.plist";
	NSString* precompiledSuffix = @".pch";
	NSArray* folderContents = [fileManager contentsOfDirectoryAtPath:targetProjectFolderPath error:&internalError];
	[KKToolHelper alertWithError:internalError];
	
	for (NSString* file in folderContents)
	{
		if ([file hasSuffix:infoPlistSuffix] || [file hasSuffix:precompiledSuffix])
		{
			// rename by moving the file
			NSString* newFilename = [file stringByReplacingOccurrencesOfString:_name withString:newProjectName];
			NSString* oldPath = [NSString stringWithFormat:@"%@/%@", targetProjectFolderPath, file];
			NSString* newPath = [NSString stringWithFormat:@"%@/%@", targetProjectFolderPath, newFilename];
			[fileManager moveItemAtPath:oldPath toPath:newPath error:&internalError];
			[KKToolHelper alertWithError:internalError];
			
			if ([file hasSuffix:infoPlistSuffix])
			{
				// also update/reset some info.plist settings
				NSDate* now = [NSDate date];
				NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
				[dateFormatter setDateFormat:@"yyyy"];
				NSString* copyright = [NSString stringWithFormat:@"Copyright © %@ %@. All rights reserved.",
									   [dateFormatter stringFromDate:now], NSFullUserName()];

				NSMutableDictionary* plist = [NSMutableDictionary dictionaryWithContentsOfFile:newPath];
				[plist setObject:copyright forKey:@"NSHumanReadableCopyright"];
				[plist setObject:name forKey:@"CFBundleDisplayName"];
				[plist setObject:@"${PRODUCT_NAME}" forKey:@"CFBundleName"];
				[plist setObject:@"${EXECUTABLE_NAME}" forKey:@"CFBundleExecutable"];
				[plist setObject:@"1.0" forKey:@"CFBundleVersion"];
				[plist setObject:@"1.0" forKey:@"CFBundleShortVersionString"];
				[plist writeToFile:newPath atomically:YES];
			}
		}
	}
	
	return YES;
}

-(void) deleteUserDataFromProjectAtPath:(NSString*)path projectFile:(NSString*)projectFile
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSError* internalError;
	
	path = [NSString stringWithFormat:@"%@/%@", path, projectFile];
	
	// delete project xcuserdata
	BOOL isDirectory;
	NSString* userdataPath = [NSString stringWithFormat:@"%@/xcuserdata", path];
	if ([fileManager fileExistsAtPath:userdataPath isDirectory:&isDirectory] && isDirectory)
	{
		[fileManager removeItemAtPath:userdataPath error:&internalError];
		[KKToolHelper alertWithError:internalError];
	}

	// delete project xcshareddata
	userdataPath = [NSString stringWithFormat:@"%@/xcshareddata", path];
	if ([fileManager fileExistsAtPath:userdataPath isDirectory:&isDirectory] && isDirectory)
	{
		[fileManager removeItemAtPath:userdataPath error:&internalError];
		[KKToolHelper alertWithError:internalError];
	}

	// delete workspace xcuserdata
	NSString* workspacePath = [NSString stringWithFormat:@"%@/project.xcworkspace", path];
	userdataPath = [NSString stringWithFormat:@"%@/xcuserdata", workspacePath];
	if ([fileManager fileExistsAtPath:userdataPath isDirectory:&isDirectory] && isDirectory)
	{
		[fileManager removeItemAtPath:userdataPath error:&internalError];
		[KKToolHelper alertWithError:internalError];
	}
	
	// delete workspace xcshareddata
	userdataPath = [NSString stringWithFormat:@"%@/xcshareddata", workspacePath];
	if ([fileManager fileExistsAtPath:userdataPath isDirectory:&isDirectory] && isDirectory)
	{
		[fileManager removeItemAtPath:userdataPath error:&internalError];
		[KKToolHelper alertWithError:internalError];
	}
}

@end
