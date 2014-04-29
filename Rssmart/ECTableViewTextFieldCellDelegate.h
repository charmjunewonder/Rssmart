//
//  ECTableViewTextFieldCellDelegate.h
//  Rssmart
//
//  Created by charmjunewonder on 4/29/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class ECPost;
@class ECTableViewTextFieldCell;

@protocol ECTableViewTextFieldCellDelegate <NSObject>

- (ECPost *)tableViewTextFieldCell:(ECTableViewTextFieldCell *)tableViewTextFieldCell postForRow:(NSInteger)rowIndex;

@end
