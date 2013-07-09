//
//  KKDownloadProjectFiles
//  KoboldKit
//
//  Created by Steffen Itterheim on 05.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

/** nd */
typedef void (^KKDownloadProjectFilesCompletionBlock)(NSDictionary* contents);

@class KKModel;

/** nd */
@interface KKDownloadProjectFiles : NSObject
{
	KKDownloadProjectFilesCompletionBlock _completionBlock;
}

/** (nd) */
+(id) downloadProjectFilesWithURL:(NSURL*)url completionBlock:(KKDownloadProjectFilesCompletionBlock)completionBlock;
/** (nd) */
-(id) initWithURL:(NSURL*)url completionBlock:(KKDownloadProjectFilesCompletionBlock)completionBlock;

@end
