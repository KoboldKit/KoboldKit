//
//  KKDownloadProjectFiles
//  KoboldKit
//
//  Created by Steffen Itterheim on 05.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KKDownloadProjectFilesCompletionBlock)(NSDictionary* contents);

/** nd */
@interface KKDownloadProjectFiles : NSObject
{
	NSURL* _url;
	NSString* _appSupportFolder;
	KKDownloadProjectFilesCompletionBlock _completionBlock;
}

+(id) downloadProjectFilesWithURL:(NSURL*)url appSupportFolder:(NSString*)appSupportFolder completionBlock:(KKDownloadProjectFilesCompletionBlock)completionBlock;
-(id) initWithURL:(NSURL*)url appSupportFolder:(NSString*)appSupportFolder completionBlock:(KKDownloadProjectFilesCompletionBlock)completionBlock;

@end
