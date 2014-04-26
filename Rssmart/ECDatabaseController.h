//
//  ECDatabaseController.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class ECSubscriptionFolder;

@interface ECDatabaseController : NSObject

+ (void)addSubscriptionForUrlString:(NSString *)url;
+ (void)loadFromDatabaseTo:(ECSubscriptionFolder *)subscriptions;

@end
