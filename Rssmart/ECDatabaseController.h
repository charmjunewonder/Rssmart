//
//  ECDatabaseController.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class ECSubscriptionItem;

@interface ECDatabaseController : NSObject

+ (void)addSubscriptionForUrlString:(NSString *)url toFolder:(ECSubscriptionItem *)folder refreshImmediately:(BOOL)shouldRefresh;
+ (void)loadFromDatabaseTo:(ECSubscriptionItem *)subscriptions;

@end
