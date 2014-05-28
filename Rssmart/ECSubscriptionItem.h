//
//  ECSubscriptionItem.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class ECSubscriptionFolder;

@interface ECSubscriptionItem : NSObject

@property (assign, nonatomic) NSInteger dbId;
@property (copy) NSString *title;
@property (assign, nonatomic) BOOL isGroupItem;
@property (assign, nonatomic) BOOL isEditable;
@property (assign, nonatomic) BOOL isDraggable;
@property (assign, nonatomic) BOOL isCollection;
@property (assign, nonatomic) NSInteger badgeValue;
@property (copy) NSImage *icon;
@property (retain) NSDate *iconLastRefreshed;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) ECSubscriptionFolder *parentFolderReference;
@property (retain, nonatomic) NSMutableArray *children;

- (NSString *)extractTitleForDisplay;

@end
