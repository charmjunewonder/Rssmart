//
//  ECSubscriptionFeed.m
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECSubscriptionFeed.h"
#import "FMResultSet.h"
#import "ECConstants.h"
#import "ECTimer.h"

@interface ECSubscriptionFeed (Private)
- (void)populateUsingResultSet:(FMResultSet *)rs;
@end

@implementation ECSubscriptionFeed

@synthesize url;
@synthesize websiteLink;
@synthesize postsToAddToDB;
@synthesize lastSyncPosts;

- (id)init {
	self = [super init];
	
	if (self != nil) {
		[self setIsEditable:YES];
		[self setIsDraggable:YES];
	}
	
	return self;
}

- (id)initWithResultSet:(FMResultSet *)rs {
	self = [self init];
	
	if (self != nil) {
		[self populateUsingResultSet:rs];
	}
	
	return self;
}

- (void)dealloc {
	[url release];
	[websiteLink release];
	[postsToAddToDB release];
	[lastSyncPosts release];
	
	[super dealloc];
}

- (void)populateUsingResultSet:(FMResultSet *)rs {
	[self setDbId:[rs longForColumn:@"Id"]];
	[self setUrl:[rs stringForColumn:@"Url"]];
	[self setTitle:[rs stringForColumn:@"Title"]];
	
	NSData *iconData = [rs dataForColumn:@"Icon"];
	
	if (iconData != nil) {
		[self setIcon:[NSUnarchiver unarchiveObjectWithData:iconData]];
	}
	
	[self setBadgeValue:[rs longForColumn:@"UnreadCount"]];
	[self setIconLastRefreshed:[rs dateForColumn:@"IconLastRefreshed"]];
	[self setWebsiteLink:[rs stringForColumn:@"WebsiteLink"]];
	
	NSData *lastSyncPostsData = [rs dataForColumn:@"LastSyncPosts"];
	
	if (lastSyncPostsData != nil) {
		[self setLastSyncPosts:[NSUnarchiver unarchiveObjectWithData:lastSyncPostsData]];
	}
}

- (void)startIconRefreshTimer{

}

@end