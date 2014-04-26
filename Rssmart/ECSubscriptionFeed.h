//
//  ECSubscriptionFeed.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECSubscriptionItem.h"

@class FMResultSet;

@interface ECSubscriptionFeed :ECSubscriptionItem

@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *websiteLink;
@property (retain, nonatomic) NSArray *postsToAddToDB;
@property (retain, nonatomic) NSMutableArray *lastSyncPosts;

- (id)initWithResultSet:(FMResultSet *)rs;

@end
