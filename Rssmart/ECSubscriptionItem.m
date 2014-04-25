//
//  ECSubscriptionItem.m
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECSubscriptionItem.h"
#import "ECSubscriptionFeed.h"

@implementation ECSubscriptionItem

@synthesize title;
@synthesize children;
@synthesize isGroupItem;
@synthesize isEditable;
@synthesize isDraggable;
@synthesize badgeValue;
@synthesize icon;
@synthesize iconLastRefreshed;
@synthesize isLoading;

- (id)init {
	self = [super init];
	if (self != nil) {
		[self setChildren:[NSMutableArray array]];
		[self setIsGroupItem:NO];
		[self setIsEditable:NO];
		[self setIsDraggable:NO];
		[self setBadgeValue:0];
		[self setIsLoading:NO];
	}
	return self;
}

- (void)dealloc {
	[title release];
	[children release];
	[icon release];
	[iconLastRefreshed release];
	
	[super dealloc];
}

// extract some form of a title from this item for use in source list, etc
- (NSString *)extractTitleForDisplay {
	NSString *builtTitle = @"";
	
	if ([self title] != nil && [[self title] length] > 0) {
		builtTitle = [self title];
	} else if ([self isKindOfClass:[ECSubscriptionFeed class]]) {
		if ([(ECSubscriptionFeed *)self url] != nil && [[(ECSubscriptionFeed *)self url] length] > 0) {
			builtTitle = [(ECSubscriptionFeed *)self url];
		}
	}
	
	return builtTitle;
}

@end
