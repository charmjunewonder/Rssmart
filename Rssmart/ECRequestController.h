//
//  ECRequestController.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECOperationDelegate.h"
#import "ECFeedRequestDelegate.h"
#import "ECRequest.h"

@interface ECRequestController : NSObject <ECOperationDelegate, ECFeedRequestDelegate>

@property (retain, nonatomic) NSMutableArray *iconRefreshTimers;
@property (retain, nonatomic) NSOperationQueue *operationQueue;
@property (assign, nonatomic) NSInteger numberOfActiveParseOps;
@property (retain, nonatomic) NSMutableArray *requestQueue;
@property (assign, nonatomic) BOOL requestInProgress;
@property (assign, nonatomic) ECRequestType activeRequestType;
@property (retain, nonatomic) NSMutableArray *feedsToSync;
@property (retain, nonatomic) NSMutableArray *feedRequests;

+ (ECRequestController *)getSharedInstance;

- (void)startToRequestIconForFeed:(ECSubscriptionFeed *)feed;
- (void)queueSyncRequestForSpecificFeeds:(NSMutableArray *)feeds;
- (void)runDatabaseUpdateOnBackgroundThread:(NSString *)queryString, ... NS_REQUIRES_NIL_TERMINATION;
- (void)queueIconRefreshOperationFor:(ECSubscriptionFeed *)feed;
- (void)addTimerOfIconRequestForFeed:(ECSubscriptionFeed *)feed forTimeInterval:(NSTimeInterval) interval;
- (void)startToOperate;
- (void)queueAllFeedsSyncRequest:(ECSubscriptionItem *)subscriptionRoot;
- (void)removeFromRequestForFeed:(ECSubscriptionFeed *)feed;

@end
