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

/** nd */
extern NSString* const KKDownloadProjectFilesURL;
/** nd */
extern NSString* const KKDownloadProjectFilesAppSupportFolder;

@class KKModel;

/** nd */
@interface KKDownloadProjectFiles : NSObject
{
	NSString* _appSupportDir;
	KKDownloadProjectFilesCompletionBlock _completionBlock;
}

/** (nd) */
+(id) downloadProjectFilesWithModel:(KKModel*)model completionBlock:(KKDownloadProjectFilesCompletionBlock)completionBlock;
/** (nd) */
-(id) initWithModel:(KKModel*)model completionBlock:(KKDownloadProjectFilesCompletionBlock)completionBlock;

@end
