//
//  ECFeedParserOperationDelegate.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECOperationDelegate.h"

@class ECSubscriptionFeed;

@protocol ECFeedParserOperationDelegate <NSObject>

- (void)feedParserOperationFoundNewPostsForFeed:(ECSubscriptionFeed *)feed;
- (void)feedParserOperationFoundTitleForFeed:(ECSubscriptionFeed *)feed;
- (void)feedParserOperationFoundWebsiteLinkForFeed:(ECSubscriptionFeed *)feed;

@end
