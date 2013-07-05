//
//  KKDownloadProjectFiles
//  KoboldKit
//
//  Created by Steffen Itterheim on 05.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKDownloadProjectFiles.h"
#import <netinet/in.h>
#import "Reachability.h"
#import "KKModel.h"

NSString* const KKDownloadProjectFilesURL = @"KKDownloadProjectFiles:URL";
NSString* const KKDownloadProjectFilesAppSupportFolder = @"KKDownloadProjectFiles:AppSupportFolder";

@implementation KKDownloadProjectFiles

+(id) downloadProjectFilesWithModel:(KKModel*)model completionBlock:(KKDownloadProjectFilesCompletionBlock)completionBlock
{
	return [[self alloc] initWithModel:model completionBlock:completionBlock];
}

-(id) initWithModel:(KKModel*)model completionBlock:(KKDownloadProjectFilesCompletionBlock)completionBlock
{
	self = [super init];
	if (self)
	{
		_completionBlock = [completionBlock copy];
		
		_appSupportDir = [NSString stringWithFormat:@"%@/%@",
						  [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject],
						  [model objectForKey:KKDownloadProjectFilesAppSupportFolder]];
		[[NSFileManager defaultManager] createDirectoryAtPath:_appSupportDir withIntermediateDirectories:YES attributes:nil error:nil];
		
		NSDictionary* remoteFiles = [self directoryContentsOfURL:[model objectForKey:KKDownloadProjectFilesURL]];
		[self performSelectorInBackground:@selector(downloadRemoteFiles:) withObject:remoteFiles];
	}
	return self;
}

-(void) downloadRemoteFiles:(NSDictionary*)remoteFiles
{
	// simply copy all files to app support dir
	if (remoteFiles)
	{
		dispatch_group_t dispatchGroup = dispatch_group_create();
		dispatch_queue_t dispatchQueue = dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);
		
		for (NSURL* key in remoteFiles)
		{
			NSArray* files = [remoteFiles objectForKey:key];
			for (NSString* file in files)
			{
				NSURL* fileURL = [key URLByAppendingPathComponent:file];
				if ([self remoteFileIsNewer:fileURL])
				{
					dispatch_group_async(dispatchGroup, dispatchQueue, ^{
						NSData* data = [NSData dataWithContentsOfURL:fileURL];
						NSString* saveFile = [_appSupportDir stringByAppendingPathComponent:file];
						if ([data writeToFile:saveFile atomically:YES] == NO)
						{
							NSLog(@"FILE SAVE FAILED!");
							LOG_EXPR(saveFile);
						}
						
						NSLog(@"File downloaded: %@", [saveFile lastPathComponent]);
					});
				}
			}
		}
		
		dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		_completionBlock(remoteFiles);
	});
}

-(BOOL) remoteFileIsNewer:(NSURL*)remoteFileURL
{
	NSError* error;
	
	// get the file attributes to retrieve the local file's modified date
	NSString* localFile = [NSString stringWithFormat:@"%@/%@", _appSupportDir, [remoteFileURL lastPathComponent]];
	NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:localFile error:&error];
	if (error)
	{
		return YES;
	}
	
	// create a HTTP request to get the file information from the web server
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:remoteFileURL];
	[request setHTTPMethod:@"HEAD"];
	
	NSHTTPURLResponse* response;
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if (error)
	{
		LOG_EXPR(error);
		return YES;
	}
	
	// get the last modified info from the HTTP header
	NSString* httpLastModified = nil;
	if ([response respondsToSelector:@selector(allHeaderFields)])
	{
		httpLastModified = [[response allHeaderFields] objectForKey:@"Last-Modified"];
	}
	
	// setup a date formatter to query the server file's modified date
	NSDateFormatter* df = [[NSDateFormatter alloc] init];
	df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
	df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
	
	// test if the server file's date is later than the local file's date
	NSDate* serverFileDate = [df dateFromString:httpLastModified];
	NSDate* localFileDate = [fileAttributes fileModificationDate];
	BOOL isNewer = ([localFileDate laterDate:serverFileDate] == serverFileDate);
	return isNewer;
}

-(BOOL) isReachable:(NSURL*)url
{
	if ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus != ReachableViaWiFi)
	{
		NSLog(@"WARNING: Wifi not enabled, can't connect to URL: %@", url);
		return NO;
	}
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	request.timeoutInterval = 1.0;
	request.HTTPMethod = @"HEAD";
	
	NSError* error;
	NSHTTPURLResponse* response;
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if (error)
	{
		NSLog(@"WARNING: Host or port not reachable: %@ - %@", url, error.localizedDescription);
		return NO;
	}
	
	return YES;
}

-(NSDictionary*) directoryContentsOfURL:(NSURL*)url
{
	NSMutableDictionary* contents = nil;
	
	if ([self isReachable:url])
	{
		contents = [NSMutableDictionary dictionary];
		[self readDirectoryContentsOfURL:url path:@"/" contents:contents];
	}
	
	return contents;
}

-(void) readDirectoryContentsOfURL:(NSURL*)url path:(NSString*)path contents:(NSMutableDictionary*)contents
{
	path = [path stringByRemovingPercentEncoding];
	url = [url URLByAppendingPathComponent:path];
	
	NSError* error;
	NSString* html = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
	if (html.length == 0)
	{
		NSLog(@"WARNING: could not load directory contents of URL: %@ - Reason: %@", url, error);
		return;
	}
	
	NSArray* components = [html componentsSeparatedByString:@"<li><a href="];
	NSMutableArray* folders = [NSMutableArray arrayWithCapacity:components.count];
	NSMutableArray* files = [NSMutableArray arrayWithCapacity:components.count];
	
	for (NSString* component in components)
	{
		NSRange range = [component rangeOfString:@"\">"];
		if ([component hasPrefix:@"\""] && range.location != NSNotFound)
		{
			range.length = range.location - 1;
			range.location = 1;
			NSString* pathOrFile = [component substringWithRange:range];
			
			[pathOrFile hasSuffix:@"/"] ? [folders addObject:pathOrFile] : [files addObject:[pathOrFile stringByRemovingPercentEncoding]];
		}
	}
	
	[contents setObject:files forKey:[url absoluteURL]];
	
	for (NSString* folder in folders)
	{
		[self readDirectoryContentsOfURL:url path:folder contents:contents];
	}
}

@end
