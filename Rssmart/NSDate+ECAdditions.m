//
//  NSDate+ECAdditions.m
//  Rssmart
//
//  Created by charmjunewonder on 4/29/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "NSDate+ECAdditions.h"

@implementation NSDate (ECAdditions)

- (NSString *)ecStringForDisplay {
	NSString *display;
	NSDate *now = [NSDate date];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *receiverDateString = [dateFormatter stringFromDate:self];
	NSString *nowDateString = [dateFormatter stringFromDate:now];
	
	if ([receiverDateString isEqual:nowDateString]) {
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		display = [dateFormatter stringFromDate:self];
	} else {
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		display = [dateFormatter stringFromDate:self];
	}
	
	[dateFormatter release];
	
	if (display == nil) {
		return @"";
	}
	
	return display;
}

@end
