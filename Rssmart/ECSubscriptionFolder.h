//
//  ECSubscriptionFolder.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECSubscriptionItem.h"

@interface ECSubscriptionFolder : ECSubscriptionItem

@property (assign, nonatomic) NSInteger dbId;
@property (copy, nonatomic) NSString *path;
@property (assign, nonatomic) ECSubscriptionFolder *parentFolderReference;

@end
