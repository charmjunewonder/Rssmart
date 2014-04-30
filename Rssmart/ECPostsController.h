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
@class ECArticleController;

@interface ECPostsController : NSObject < NSTableViewDataSource, NSTableViewDelegate, ECTableViewTextFieldCellDelegate>

@property (assign, nonatomic) ECArticleController *articleController;

@property (assign, nonatomic) IBOutlet ECTableView *tableView;
@property (retain, nonatomic) NSMutableArray *posts;
@property (assign, nonatomic) ECSubscriptionItem *selectedItem;
@property (assign, nonatomic) NSString *searchQuery;

+ (ECPostsController *)getSharedInstance;

- (void)setup;

#pragma mark Load Post to TableView
- (void)openSubscriptionItem:(ECSubscriptionItem *)item orQuery:(NSString *)queryString;
- (void)reloadDataInTableView;
#pragma mark -


@end
