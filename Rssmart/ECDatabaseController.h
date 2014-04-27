//
//  ECDatabaseController.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class ECSubscriptionItem;
@class ECSubscriptionFeed;

@interface ECDatabaseController : NSObject

+ (void)addSubscriptionForUrlString:(NSString *)url toFolder:(ECSubscriptionItem *)folder refreshImmediately:(BOOL)shouldRefresh;
+ (void)loadFromDatabaseTo:(ECSubscriptionItem *)subscriptions;
+ (NSMutableArray *)checkIfPostsNotExists:(NSMutableArray *)probablyNewPosts;
+ (void)updateLastSyncPosts:(NSMutableArray *)syncPosts forFeed:(ECSubscriptionFeed *)feed;
+ (void)updateWebsiteLink:(NSString *)webLink forFeed:(ECSubscriptionFeed *)feed;
+ (void)addToDatabaseForPosts:(NSArray *)posts forFeed:(ECSubscriptionFeed *)feed;
+ (void)updateDatabaseForQueries:(NSArray *)queries;
@end
