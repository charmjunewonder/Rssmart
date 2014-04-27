//
//  ECRequestController.m
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECRequestController.h"
#import "ECSubscriptionFeed.h"
#import "ECTimer.h"
#import "ECIconRefreshOperation.h"
#import "ECConstants.h"
#import "ECSubscriptionsController.h"

#define ICON_REFRESH_INTERVAL TIME_INTERVAL_MONTH

@implementation ECRequestController

@synthesize iconRefreshTimers;
@synthesize operationQueue;
@synthesize feedsToSync;
@synthesize feedRequests;
@synthesize numberOfActiveParseOps;
@synthesize requestQueue;
@synthesize requestInProgress;
@synthesize activeRequestType;

static ECRequestController *_sharedInstance = nil;

+ (ECRequestController *)getSharedInstance
{
    if(_sharedInstance == nil)
        @synchronized(self) {
            if(_sharedInstance == nil)
                _sharedInstance = [[ECRequestController alloc] init];
        }
    return _sharedInstance;
}

/*
 * Note that at this time, connected IBOutlet is nil.
 */
-(id)init
{
    NSAssert(_sharedInstance == nil, @"Duplication initialization of singleton");
    self = [super init];
    _sharedInstance = self;
    if (self != nil) {
        [self setOperationQueue:[[[NSOperationQueue alloc] init] autorelease]];
		[operationQueue setMaxConcurrentOperationCount:2];
		[self setIconRefreshTimers:[NSMutableArray array]];

    }
    return self;
}

- (void)timeToAddFeedToIconQueue:(ECTimer *)timer {
	ECSubscriptionFeed *feed = [timer userInfo];
	[self queueIconRefreshOperationFor:feed];
	[iconRefreshTimers removeObject:timer];
}

- (void)queueIconRefreshOperationFor:(ECSubscriptionFeed *)feed {
	ECIconRefreshOperation *iconOp = [[ECIconRefreshOperation alloc] init];
	[iconOp setFeed:feed];
	[iconOp setDelegate:[ECSubscriptionsController getSharedInstance]];
	
	[operationQueue addOperation:iconOp];
	[iconOp release];
}

- (void)startToRequestIconForFeed:(ECSubscriptionFeed *)feed{
    [feed setWebsiteLink:@"http://www.zhihu.com"];
    // refresh the icon (if we have the link for this feed)
    if ([feed websiteLink] != nil && [[feed websiteLink] length] > 0) {
        NSTimeInterval iconRefreshTimeLapsed = 0.0;
        NSTimeInterval iconRefreshDelay = 0.0;
        NSTimeInterval minRefreshDelay = (TIME_INTERVAL_MINUTE * 10);
        
        if ([feed iconLastRefreshed] != nil) {
            iconRefreshTimeLapsed = [[NSDate date] timeIntervalSinceDate:[feed iconLastRefreshed]];
        }
        
        if ([feed iconLastRefreshed] == nil || iconRefreshTimeLapsed > ICON_REFRESH_INTERVAL) {
            iconRefreshDelay = minRefreshDelay;
        } else {
            iconRefreshDelay = ICON_REFRESH_INTERVAL - iconRefreshTimeLapsed;
        }
        
        if (iconRefreshDelay < minRefreshDelay) {
            iconRefreshDelay = minRefreshDelay;
        }
        iconRefreshDelay = 1;
        ECTimer *iconTimer = [ECTimer scheduledTimerWithTimeInterval:iconRefreshDelay target:self selector:@selector(timeToAddFeedToIconQueue:) userInfo:feed repeats:NO];
        [iconRefreshTimers addObject:iconTimer];
    }
}


#pragma mark CLOperationDelegate
- (void)didStartOperation:(ECOperation *)op {
	
}

- (void)didFinishOperation:(ECOperation *)op {
//	if ([op isKindOfClass:[CLFeedParserOperation class]]) {
//		
//		
//		[self setNumberOfActiveParseOps:(numberOfActiveParseOps-1)];
//		
//		[self startFeedRequests];
//		
//	}
//	
//	if (requestInProgress) {
//		if ([operationQueue operationCount] == 1) {
//			if (activeRequestType == ECRequestAllFeedsSync || activeRequestType == ECRequestSpecificFeedsSync) {
//				if ([feedRequests count] == 0 && [feedsToSync count] == 0) {
//					[self setRequestInProgress:NO];
//					[self startRequestIfNoneInProgress];
//				}
//			} else if (activeRequestType == ECRequestDeleteHidden) {
//				[self setRequestInProgress:NO];
//				[self startRequestIfNoneInProgress];
//			}
//		}
//	}
}
#pragma mark -



@end
