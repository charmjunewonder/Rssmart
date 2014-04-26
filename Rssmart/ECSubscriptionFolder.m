//
//  ECSubscriptionFolder.m
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECSubscriptionFolder.h"
#import "ECSubscriptionFeed.h"

@implementation ECSubscriptionFolder

@synthesize path;

- (id)init {
	self = [super init];
	if (self != nil) {
        [self setChildren:[NSMutableArray array]];
		[self setIsEditable:YES];
		[self setIsDraggable:YES];
		[self setIcon:[NSImage imageNamed:NSImageNameFolder]];
	}
	return self;
}

- (void)dealloc {
	
	// zero weak refs
    //TODO:children
	for (ECSubscriptionItem *item in [super children]) {
		if ([item isKindOfClass:[ECSubscriptionFeed class]]) {
			[(ECSubscriptionFeed *)item setParentFolderReference:nil];
		} else if ([item isKindOfClass:[ECSubscriptionFolder class]]) {
			[(ECSubscriptionFolder *)item setParentFolderReference:nil];
		}
	}
    [[super children] release];

	[path release];
	
	[super dealloc];
}

@end
