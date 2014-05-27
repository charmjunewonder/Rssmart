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

- (void)dealloc {
    [windowController release];
    
	[super dealloc];
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
	
	
	
//	[self updateMenuItems];
	
    //	return windowController;
}



@end
