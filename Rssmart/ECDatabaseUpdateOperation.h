//
//  ECDatabaseUpdateOperation.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECOperation.h"

@interface ECDatabaseUpdateOperation : ECOperation

@property (copy, nonatomic) NSArray *queries;

@end
