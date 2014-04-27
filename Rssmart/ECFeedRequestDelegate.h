//
//  ECFeedRequestDelegate.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class ECFeedRequest;
@class ECSubscriptionFeed;

@protocol ECFeedRequestDelegate <NSObject>

- (void)feedRequest:(ECFeedRequest *)feedRequest didFinishWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

@end
