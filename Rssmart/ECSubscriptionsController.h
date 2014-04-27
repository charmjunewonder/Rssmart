//
//  ECSubscriptionsController.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//
#import "ECIconRefreshOperationDelegate.h"

@class ECSubscriptionsView;
@class ECSubscriptionItem;
@class ECSubscriptionFeed;
@class ECSubscriptionFolder;
@class ECAddFeedController;

@interface ECSubscriptionsController : NSObject <NSOutlineViewDataSource,
NSOutlineViewDelegate, ECIconRefreshOperationDelegate>

@property (retain, nonatomic) NSMutableArray *subscriptionList;
@property (assign, nonatomic) IBOutlet ECSubscriptionsView *subsView;
//feeds that are at the top containing 'Library' and 'Subscriptions'
@property (retain, nonatomic) ECSubscriptionItem *subscriptionRoot;
//feeds that contains new posts
@property (retain, nonatomic) ECSubscriptionItem *subscriptionNewItems;
//feeds that contains starred posts
@property (retain, nonatomic) ECSubscriptionItem *subscriptionStarredItems;
//feeds that contains all posts
@property (retain, nonatomic) ECSubscriptionItem *subscriptionSubscriptions;
@property (retain, nonatomic) ECSubscriptionItem *subscriptionSelectedItem;
@property (assign, nonatomic) ECSubscriptionItem *subscriptionDragItem;
@property (assign, nonatomic) IBOutlet ECAddFeedController *addFeedController;

+ (ECSubscriptionsController *)getSharedInstance;

-(void)setup;

- (IBAction)addSubscription:(id)sender;
- (IBAction)addSubscriptionForSure:(id)sender;

@end
