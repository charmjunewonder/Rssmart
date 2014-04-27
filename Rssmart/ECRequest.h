//
//  ECRequest.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

typedef enum {ECRequestAllFeedsSync, ECRequestSpecificFeedsSync, ECRequestDeleteHidden} ECRequestType;

@class ECSubscriptionFeed;

@interface ECRequest : NSObject

@property (assign, nonatomic) ECRequestType requestType;
@property (retain, nonatomic) NSArray *specificFeeds;
@property (retain, nonatomic) ECSubscriptionFeed *singleFeed;

@end
