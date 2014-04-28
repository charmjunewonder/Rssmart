//
//  ECWindowController.m
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECWindowController.h"
#import "ECSubscriptionsController.h"
#import "ECSubscriptionsView.h"

@interface ECWindowController ()

@end

@implementation ECWindowController

@synthesize subsController;

- (id)init {
	self = [super initWithWindowNibName:@"MainWindow"];
	if (self != nil) {
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}
/*
 * Now then all the outlet are set.
 */
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    subsController = [ECSubscriptionsController getSharedInstance];
//    [[self window] makeFirstResponder:[[self window] contentView]];
//    [[self window] makeFirstResponder:[subsController subsView]];
    [subsController setup];
}

//- (void)updateFirstResponder {
//	BOOL returnVal = NO;
//    returnVal = [[self window] makeFirstResponder:[[subsController subsView] tableView]];
//
//}


@end
