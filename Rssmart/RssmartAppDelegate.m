//
//  ECAppDelegate.m
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "RssmartAppDelegate.h"
#import "ECWindowController.h"

@interface RssmartAppDelegate (Private)
- (void)newWindow;
@end

@implementation RssmartAppDelegate

@synthesize windowController;

- (id)init {
	self = [super init];
	
	if (self != nil) {
	}
	
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self newWindow];
}

- (void)newWindow {
	windowController = [[ECWindowController alloc] init];
//	[windowController setSubscriptionList:subscriptionList];
	[windowController showWindow:self];
	
//	if (isFirstWindow) {
//		NSUInteger numUnread = [windowController updateBadgeValuesFor:subscriptionList];
//		[self changeNewItemsBadgeValueBy:numUnread];
//		[self setIsFirstWindow:NO];
//	} else {
//		[[windowController subscriptionNewItems] setBadgeValue:totalUnread];
//	}
	
//	[[windowController subsController] selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
	
//	[self updateMenuItems];
	
    //	return windowController;
}



@end
