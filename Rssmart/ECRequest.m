//
//  ECRequest.m
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECRequest.h"

@implementation ECRequest

@synthesize requestType;
@synthesize specificFeeds;
@synthesize singleFeed;

- (void)dealloc {
	[specificFeeds release];
	[singleFeed release];
	
	[super dealloc];
}

@end
