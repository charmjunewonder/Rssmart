//
//  ECTableViewTextFieldCell.h
//  Rssmart
//
//  Created by charmjunewonder on 4/29/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECTableViewTextFieldCellDelegate.h"

@class ECTableView;

@interface ECTableViewTextFieldCell : NSTextFieldCell

@property (assign, nonatomic) id <ECTableViewTextFieldCellDelegate> delegate;
@property (assign, nonatomic) NSInteger rowIndex;
@property (assign, nonatomic) ECTableView *tableViewReference;

@end
