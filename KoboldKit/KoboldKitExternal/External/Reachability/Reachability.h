/*
 Copyright (c) 2011, Tony Million.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE. 
 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

/*
 * Does ARC support support GCD objects?
 * It does if the minimum deployment target is iOS 6+ or Mac OS X 8+
 * 
 * @see http://opensource.apple.com/source/libdispatch/libdispatch-228.18/os/object.h
 */
#if OS_OBJECT_USE_OBJC
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif


/** not documented */
extern NSString *const kReachabilityChangedNotification;

/** not documented */
typedef enum
{
	// Apple NetworkStatus Compatible Names.
	NotReachable     = 0,
	ReachableViaWiFi = 2,
	ReachableViaWWAN = 1
} NetworkStatus;

@class Reachability;

/** not documented */
typedef void (^NetworkReachable)(Reachability * reachability);
/** not documented */
typedef void (^NetworkUnreachable)(Reachability * reachability);

/** Tony Million's Reachability class: https://github.com/tonymillion/Reachability */
@interface Reachability : NSObject

/** not documented */
@property (nonatomic, copy) NetworkReachable    reachableBlock;
/** not documented */
@property (nonatomic, copy) NetworkUnreachable  unreachableBlock;

/** not documented */
@property (nonatomic, assign) BOOL reachableOnWWAN;

/** not documented
 @param hostname The host name (URL). */
+(Reachability*)reachabilityWithHostName:(NSString*)hostname;
/** not documented */
+(Reachability*)reachabilityForInternetConnection;
/** not documented
 @param hostAddress .. */
+(Reachability*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;
/** not documented */
+(Reachability*)reachabilityForLocalWiFi;
/** not documented
 @param ref .. */
-(Reachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

/** not documented */
-(BOOL)startNotifier;
/** not documented */
-(void)stopNotifier;

/** not documented */
-(BOOL)isReachable;
/** not documented */
-(BOOL)isReachableViaWWAN;
/** not documented */
-(BOOL)isReachableViaWiFi;

/** @returns Identical DDG variant. */
-(BOOL)isConnectionRequired;
/** @returns Apple's routine. */
-(BOOL)connectionRequired;
/** @returns Dynamic, on demand connection? */
-(BOOL)isConnectionOnDemand;
/** @returns Is user intervention required? */
-(BOOL)isInterventionRequired;

/** not documented */
-(NetworkStatus)currentReachabilityStatus;
/** not documented */
-(SCNetworkReachabilityFlags)reachabilityFlags;
/** not documented */
-(NSString*)currentReachabilityString;
/** not documented */
-(NSString*)currentReachabilityFlags;

@end
