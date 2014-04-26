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
    // refresh the icon (if we have the link for this feed)
//    if ([self websiteLink] != nil && [[self websiteLink] length] > 0) {
//        NSTimeInterval iconRefreshTimeLapsed = 0.0;
//        NSTimeInterval iconRefreshDelay = 0.0;
//        NSTimeInterval minRefreshDelay = (TIME_INTERVAL_MINUTE * 10);
//        
//        if ([feed iconLastRefreshed] != nil) {
//            iconRefreshTimeLapsed = [[NSDate date] timeIntervalSinceDate:[feed iconLastRefreshed]];
//        }
//        
//        if ([feed iconLastRefreshed] == nil || iconRefreshTimeLapsed > ICON_REFRESH_INTERVAL) {
//            iconRefreshDelay = minRefreshDelay;
//        } else {
//            iconRefreshDelay = ICON_REFRESH_INTERVAL - iconRefreshTimeLapsed;
//        }
//        
//        if (iconRefreshDelay < minRefreshDelay) {
//            iconRefreshDelay = minRefreshDelay;
//        }
//        
//        _iconTimer = [ECTimer scheduledTimerWithTimeInterval:iconRefreshDelay target:self selector:@selector(timeToAddFeedToIconQueue:) userInfo:feed repeats:NO];
//    }
}

@end