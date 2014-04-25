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

@synthesize dbId;
@synthesize path;
@synthesize parentFolderReference;

- (id)init {
	self = [super init];
	if (self != nil) {
		[self setIsEditable:YES];
		[self setIsDraggable:YES];
		[self setIcon:[NSImage imageNamed:NSImageNameFolder]];
	}
	return self;
}

- (void)dealloc {
	
	// zero weak refs
    //TODO:children
	for (ECSubscriptionItem *item in self.children) {
		if ([item isKindOfClass:[ECSubscriptionFeed class]]) {
			[(ECSubscriptionFeed *)item setEnclosingFolderReference:nil];
		} else if ([item isKindOfClass:[ECSubscriptionFolder class]]) {
			[(ECSubscriptionFolder *)item setParentFolderReference:nil];
		}
	}
	
	[path release];
	
	[super dealloc];
}

@end
