//
//  ECSubscriptionItem.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@interface ECSubscriptionItem : NSObject

@property (copy) NSString *title;
@property (retain, nonatomic) NSMutableArray *children;
@property (assign, nonatomic) BOOL isGroupItem;
@property (assign, nonatomic) BOOL isEditable;//TODO: maybe delete?
@property (assign, nonatomic) BOOL isDraggable;
@property (assign, nonatomic) NSInteger badgeValue;
@property (copy) NSImage *icon;
@property (retain) NSDate *iconLastRefreshed;
@property (assign, nonatomic) BOOL isLoading;

- (NSString *)extractTitleForDisplay;

@end
