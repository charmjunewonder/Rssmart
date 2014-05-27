//
//  ECOperation.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECOperationDelegate.h"

@interface ECOperation : NSOperation

@property (assign) id <ECOperationDelegate> _delegate;

- (id <ECOperationDelegate>)delegate;

- (void)setDelegate:(id <ECOperationDelegate>)delegate;
- (void)dispatchDidStartDelegateMessage;
- (void)dispatchDidFinishDelegateMessage;


@end
