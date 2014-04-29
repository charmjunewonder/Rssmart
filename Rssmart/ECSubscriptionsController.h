//
//  ECSubscriptionsController.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//
#import "ECIconRefreshOperationDelegate.h"
#import "ECFeedParserOperationDelegate.h"

@class ECSubscriptionsView;
@class ECSubscriptionItem;
@class ECSubscriptionFeed;
@class ECSubscriptionFolder;
@class ECAddFeedController;
@class ECAddFolderController;
@class ECPostsController;

@interface ECSubscriptionsController : NSObject <NSOutlineViewDataSource,
NSOutlineViewDelegate, ECIconRefreshOperationDelegate, ECFeedParserOperationDelegate>

@property (assign, nonatomic) ECPostsController *postsController;

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
@property (assign, nonatomic) ECSubscriptionFeed *subscriptionDragItem;
@property (assign, nonatomic) IBOutlet ECAddFeedController *addFeedController;
@property (assign, nonatomic) IBOutlet ECAddFolderController *addFolderController;
@property (assign, nonatomic) IBOutlet NSMenu *subsViewContextMenu;

+ (ECSubscriptionsController *)getSharedInstance;

-(void)setup;

- (IBAction)addSubscription:(id)sender;
- (IBAction)addSubscriptionForSure:(id)sender;
- (IBAction)refreshSubscriptions:(id)sender;
- (IBAction)addFolder:(id)sender;
- (IBAction)addFolderForSure:(id)sender;
- (IBAction)editFolder:(id)sender;
- (IBAction)editFolderForSure:(id)sender;
- (IBAction)deleteFolder:(id)sender;
- (void)refreshSubscriptionsView;
- (IBAction)subscriptionsItemRefresh:(id)sender;
@end
