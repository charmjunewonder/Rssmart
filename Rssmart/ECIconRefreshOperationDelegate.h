//
//  ECIconRefreshOperationDelegate.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class ECIconRefreshOperation;
@class ECSubscriptionFeed;

@protocol ECIconRefreshOperationDelegate <NSObject>

- (void)iconRefreshOperation:(ECIconRefreshOperation *)refreshOp refreshedFeed:(ECSubscriptionFeed *)feed foundIcon:(NSImage *)icon;

@end
