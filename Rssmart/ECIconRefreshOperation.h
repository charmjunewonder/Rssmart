//
//  ECIconRefreshOperation.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECOperation.h"
#import "ECIconRefreshOperationDelegate.h"

@class ECSubscriptionFeed;

@interface ECIconRefreshOperation : ECOperation

@property (assign) id <ECIconRefreshOperationDelegate> delegate;
@property (retain) ECSubscriptionFeed *feed;
@property (retain) NSImage *favicon;

- (NSImage *)faviconForUrlString:(NSString *)urlString;
- (void)dispatchIconRefreshDelegateMessage;

@end
