//
//  ECFeedParserOperation.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECOperation.h"
#import "ECFeedParserOperationDelegate.h"

@class ECSubscriptionFeed;
@class ECXMLNode;

@interface ECFeedParserOperation : ECOperation

@property (assign) id <ECFeedParserOperationDelegate> delegate;
@property (retain) ECSubscriptionFeed *feed;
@property (retain) NSData *data;
@property (assign) NSStringEncoding encoding;
@property (retain) NSMutableArray *allPosts;
@property (copy) NSString *_atomFeedAuthor;
@property (assign) NSInteger _feedType;

- (void)processNode:(ECXMLNode *)node;

- (void)dispatchNewPostsDelegateMessage;
- (void)dispatchTitleDelegateMessage;
- (void)dispatchWebsiteLinkDelegateMessage;

@end
