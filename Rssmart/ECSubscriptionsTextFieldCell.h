//
//  ECSubscriptionsTextFieldCell.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@interface ECSubscriptionsTextFieldCell : NSTextFieldCell

@property (assign, nonatomic) NSUInteger badgeWidth;
@property (assign, nonatomic) NSUInteger iconWidth;
@property (assign, nonatomic) BOOL rowIsSelected;
@property (assign, nonatomic) BOOL isEditingOrSelecting;

@end
