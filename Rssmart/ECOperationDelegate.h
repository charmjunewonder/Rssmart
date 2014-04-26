//
//  ECOperationDelegate.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class ECOperation;

@protocol ECOperationDelegate <NSObject>

- (void)didStartOperation:(ECOperation *)op;
- (void)didFinishOperation:(ECOperation *)op;

@end
