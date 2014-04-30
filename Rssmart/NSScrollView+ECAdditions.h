//
//  NSScrollView+ECAdditions.h
//  Rssmart
//
//  Created by charmjunewonder on 4/30/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//


@interface NSScrollView (ECAdditions)

- (void)ecScrollToTop;
- (void)ecScrollToBottom;
- (void)ecPageUp;
- (void)ecPageDown;
- (void)ecScrollTo:(NSPoint)scrollPoint;
- (void)ecScrollInstantlyTo:(NSPoint)scrollPoint;

@end
