//
//  ECSubscriptionsView.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@interface ECSubscriptionsView : NSOutlineView

@property (assign, nonatomic) BOOL isWindowFocused;

+ (NSSize)sizeOfBadgeForItem:(id)rowItem;

@end
