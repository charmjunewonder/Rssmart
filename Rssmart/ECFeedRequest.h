//
//  ECFeedRequest.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECFeedRequestDelegate.h"

@class ECTimer;
@class ECXMLNode;

@interface ECFeedRequest : NSObject
@property (assign) id <ECFeedRequestDelegate> delegate;
@property (retain) ECSubscriptionFeed *feed;
@property (retain) NSURLConnection *urlConnection;
@property (retain) NSURLResponse *urlResponse;
@property (retain) NSMutableData *receivedData;
@property (retain) ECTimer *safetyTimer;

- (void)startConnection;
- (void)stopConnection;

@end
