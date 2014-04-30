//
//  NSScrollView+ECAdditions.m
//  Rssmart
//
//  Created by charmjunewonder on 4/30/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "NSScrollView+ECAdditions.h"

#define SCROLL_ARROW_INCREMENT 40

@implementation NSScrollView (ECAdditions)

- (void)ecScrollToTop {
	[self ecScrollInstantlyTo:NSMakePoint(0.0, 0.0)];
}

- (void)ecScrollToBottom {
	CGFloat documentHeight = [[self contentView] documentRect].size.height;
	CGFloat clipViewHeight = [[self contentView] frame].size.height;
	
	[self ecScrollInstantlyTo:NSMakePoint(0.0, documentHeight - clipViewHeight)];
}

- (void)ecPageUp {
	NSRect documentVisibleRect = [[self contentView] documentVisibleRect];
	CGFloat originalScrollX = documentVisibleRect.origin.x;
	CGFloat originalScrollY = documentVisibleRect.origin.y;
	CGFloat pageSize = [[self contentView] frame].size.height;
	
	// not sure what the "official" way is to do this (to scroll slightly less than a page each time)
	if (pageSize > 400) {
		pageSize -= 35;
	}
	
	[self ecScrollTo:NSMakePoint(originalScrollX, originalScrollY - pageSize)];
}

- (void)ecPageDown {
	NSRect documentVisibleRect = [[self contentView] documentVisibleRect];
	CGFloat originalScrollX = documentVisibleRect.origin.x;
	CGFloat originalScrollY = documentVisibleRect.origin.y;
	CGFloat pageSize = [[self contentView] frame].size.height;
	
	// not sure what the "official" way is to do this (to scroll slightly less than a page each time)
	if (pageSize > 400) {
		pageSize -= 35;
	}
	
	[self ecScrollTo:NSMakePoint(originalScrollX, originalScrollY + pageSize)];
}

- (void)ecScrollTo:(NSPoint)scrollPoint {
	NSClipView *clipView = [self contentView];
	scrollPoint = [clipView constrainScrollPoint:scrollPoint];
	[clipView scrollToPoint:scrollPoint];
	[self reflectScrolledClipView:clipView];
}

- (void)ecScrollInstantlyTo:(NSPoint)scrollPoint {
	NSClipView *clipView = [self contentView];
	scrollPoint = [clipView constrainScrollPoint:scrollPoint];
	[clipView setBoundsOrigin:scrollPoint];
	[self reflectScrolledClipView:clipView];
}

@end
