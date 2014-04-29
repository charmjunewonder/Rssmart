//
//  ECPostsController.h
//  Rssmart
//
//  Created by charmjunewonder on 4/29/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//
#import "ECTableViewTextFieldCellDelegate.h"

@class ECTableView;
@class ECSubscriptionItem;

@interface ECPostsController : NSObject < NSTableViewDataSource, NSTableViewDelegate, ECTableViewTextFieldCellDelegate>

@property (assign, nonatomic) IBOutlet ECTableView *tableView;
@property (retain, nonatomic) NSMutableArray *posts;
@property (assign, nonatomic) ECSubscriptionItem *selectedItem;
@property (assign, nonatomic) NSString *searchQuery;

+ (ECPostsController *)getSharedInstance;

- (void)setup;

#pragma mark Load Post to TableView
//- (void)loadPostsIntoClassicView:(CLClassicView *)classicView;
//- (void)loadPostsIntoClassicView:(CLClassicView *)classicView fromRange:(NSRange)range atBottom:(BOOL)bottom;
//- (void)openItemInCurrentTab:(CLSourceListItem *)item orQuery:(NSString *)queryString;
//- (void)clearContentOfTableView;
#pragma mark -


@end
