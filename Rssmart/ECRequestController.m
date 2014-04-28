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
#import "ECFeedRequest.h"
#import "ECFeedParserOperation.h"
#import "ECPost.h"
#import "ECDatabaseUpdateOperation.h"
#import "ECSubscriptionFolder.h"

#define ICON_REFRESH_INTERVAL TIME_INTERVAL_MONTH
#define MAX_CONCURRENT_REQUESTS 2

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
        [self setFeedsToSync:[NSMutableArray array]];
		[self setFeedRequests:[NSMutableArray array]];
		[self setRequestQueue:[NSMutableArray array]];
		[self setRequestInProgress:NO];
    }
    return self;
}

- (void)startToOperate{
	[ECTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(startFeedRequests) userInfo:nil repeats:YES];
	[ECTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(startRequestIfNoneInProgress) userInfo:nil repeats:YES];
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
        ECTimer *iconTimer = [ECTimer scheduledTimerWithTimeInterval:iconRefreshDelay target:self selector:@selector(timeToAddFeedToIconQueue:) userInfo:feed repeats:NO];
        [iconRefreshTimers addObject:iconTimer];
    }
}

- (void)addTimerOfIconRequestForFeed:(ECSubscriptionFeed *)feed forTimeInterval:(NSTimeInterval) interval{
    ECTimer *iconTimer = [ECTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timeToAddFeedToIconQueue:) userInfo:feed repeats:NO];
	[iconRefreshTimers addObject:iconTimer];
}


#pragma mark CLOperationDelegate
- (void)didStartOperation:(ECOperation *)op {
	
}

- (void)didFinishOperation:(ECOperation *)op {
	if ([op isKindOfClass:[ECFeedParserOperation class]]) {
		
		[self setNumberOfActiveParseOps:(numberOfActiveParseOps-1)];
		
		[self startFeedRequests];
		
	}
	
	if (requestInProgress) {
		if ([operationQueue operationCount] == 1) {
			if (activeRequestType == ECRequestAllFeedsSync || activeRequestType == ECRequestSpecificFeedsSync) {
				if ([feedRequests count] == 0 && [feedsToSync count] == 0) {
					[self setRequestInProgress:NO];
					[self startRequestIfNoneInProgress];
				}
			} else if (activeRequestType == ECRequestDeleteHidden) {
				[self setRequestInProgress:NO];
				[self startRequestIfNoneInProgress];
			}
		}
	}
}
#pragma mark -

/*
 * Sync Specific Feeds
 */
- (void)queueSyncRequestForSpecificFeeds:(NSMutableArray *)feeds {
	
	if (feeds == nil || [feeds count] == 0) {
		return;
	}
	
	ECRequest *request = [[ECRequest alloc] init];
	[request setRequestType:ECRequestSpecificFeedsSync];
	[request setSpecificFeeds:feeds];
	
	[requestQueue addObject:request];
	[request release];
	
	[self startRequestIfNoneInProgress];
}

- (void)startRequestIfNoneInProgress {
    //check if none is in progress
	if ([feedRequests count] == 0 && [feedsToSync count] == 0 && [operationQueue operationCount] == 0) {
		[self setRequestInProgress:NO];
		[self setNumberOfActiveParseOps:0];
	}
	
	while (requestInProgress == NO && [requestQueue count] > 0) {
		
		ECRequest *request = [[[requestQueue objectAtIndex:0] retain] autorelease];
		[requestQueue removeObjectAtIndex:0];
		
		if ([request requestType] == ECRequestAllFeedsSync) {
//			NSInteger timestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
//			NSString *timestampString = [[NSNumber numberWithInteger:timestamp] stringValue];
//			[SyndicationAppDelegate miscellaneousSetValue:timestampString forKey:MISCELLANEOUS_LAST_FEED_SYNC_KEY];
			
			if ([request singleFeed] != nil) {
				[feedsToSync addObject:[request singleFeed]];
				[self startFeedRequests];
				
				[self setRequestInProgress:YES];
				[self setActiveRequestType:[request requestType]];
			}
			
		} else if ([request requestType] == ECRequestSpecificFeedsSync) {
			
			[feedsToSync addObjectsFromArray:[request specificFeeds]];
			[self startFeedRequests];
			
			[self setRequestInProgress:YES];
			[self setActiveRequestType:[request requestType]];
			
		} else if ([request requestType] == ECRequestDeleteHidden) {
			
//			[self queueDeleteHiddenOperation];
//			
//			[self setRequestInProgress:YES];
//			[self setActiveRequestType:[request requestType]];
			
		} else {
#ifndef NDEBUG
			[NSException raise:@"error" format:@"can't handle item"];
#endif
		}
	}
}

/*
 * Start to request the feed repeatly
 */
- (void)startFeedRequests {
	while ([feedsToSync count] > 0 && ([feedRequests count] + numberOfActiveParseOps) < MAX_CONCURRENT_REQUESTS) {
		
		ECSubscriptionItem *item = [feedsToSync objectAtIndex:0];
        [feedsToSync removeObjectAtIndex:0];
        
        if ([item isKindOfClass:[ECSubscriptionFeed class]]) {
            ECSubscriptionFeed *feed = (ECSubscriptionFeed *)item;
            
            
            ECFeedRequest *feedRequest = [[ECFeedRequest alloc] init];
            [feedRequest setFeed:feed];
            [feedRequest setDelegate:self];
            //TODO: why
            [feedRequests addObject:feedRequest]; // needs to be before call to startConnection
            [feedRequest release];
            
            [feedRequest startConnection];
        } else{
            ECSubscriptionFolder *folder = (ECSubscriptionFolder *)item;
            
            NSMutableArray *feeds = [folder children];
            for (ECSubscriptionFeed *feed in feeds){
                ECFeedRequest *feedRequest = [[ECFeedRequest alloc] init];
                [feedRequest setFeed:feed];
                [feedRequest setDelegate:self];
                //TODO: why
                [feedRequests addObject:feedRequest]; // needs to be before call to startConnection
                [feedRequest release];
                
                [feedRequest startConnection];
            }
        }
	}
}

/*
 * feed request finishes with data(data can be nil)
 */
- (void)feedRequest:(ECFeedRequest *)feedRequest didFinishWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
	[[feedRequest retain] autorelease];
	[feedRequests removeObject:feedRequest];
	
	if (data != nil) {
		ECFeedParserOperation *parserOp = [[ECFeedParserOperation alloc] init];
		[parserOp setDelegate:[ECSubscriptionsController getSharedInstance]];
		[parserOp setFeed:[feedRequest feed]];
		[parserOp setData:data];
		[parserOp setEncoding:encoding];
		
		[operationQueue addOperation:parserOp];
		[parserOp release];
		
		[self setNumberOfActiveParseOps:(numberOfActiveParseOps+1)];
		
	} else {
		
		if ([feedRequests count] == 0 && [feedsToSync count] == 0 && numberOfActiveParseOps == 0) {
			[self setRequestInProgress:NO];
			[self startRequestIfNoneInProgress];
		} else if ([feedRequests count] == 0) {
			[self startFeedRequests];
		}
	}
}

- (void)runDatabaseUpdateOnBackgroundThread:(NSString *)queryString, ... {
	NSMutableArray *query = [NSMutableArray array];
	[query addObject:queryString];
    
	va_list args;
	va_start(args, queryString);
    
	for (id arg = va_arg(args, id); arg != nil; arg = va_arg(args, id)) {
		[query addObject:arg];
	}
    
	va_end(args);
    
	[self runDatabaseUpdatesOnBackgroundThread:[NSArray arrayWithObject:query]];
}

- (void)runDatabaseUpdatesOnBackgroundThread:(NSArray *)queries {
	ECDatabaseUpdateOperation *dbOp = [[ECDatabaseUpdateOperation alloc] init];
	[dbOp setQueries:queries];
	[dbOp setDelegate:self];
    
	[operationQueue addOperation:dbOp];
	[dbOp release];
}

/*
 * Sync All Feeds
 */
- (void)queueAllFeedsSyncRequest:(ECSubscriptionItem *)subscriptionRoot {
	ECRequest *request = [[ECRequest alloc] init];
	[request setRequestType:ECRequestAllFeedsSync];
    [request setSingleFeed:subscriptionRoot];
	[requestQueue addObject:request];
	[request release];
	
	[self startRequestIfNoneInProgress];
}

- (void)removeFromRequestForFeed:(ECSubscriptionFeed *)feed{
    [feedsToSync removeObject:feed];
    for (ECFeedRequest *feedRequest in feedRequests) {
        if ([feedRequest feed] == feed) {
            [feedRequest stopConnection];
        }
    }
}


@end
