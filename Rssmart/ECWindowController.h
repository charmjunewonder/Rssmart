//
//  ECWindowController.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class ECSubscriptionsController;
@class ECSubscriptionsView;

@interface ECWindowController : NSWindowController

@property (assign, nonatomic) ECSubscriptionsController *subsController;
//@property (assign, nonatomic) IBOutlet ECSubscriptionsView *subsView;

@end
