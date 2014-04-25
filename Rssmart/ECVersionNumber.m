//
//  ECVersionNumber.m
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECVersionNumber.h"

@implementation ECVersionNumber

static BOOL isRunningLionOrNewer;

+ (void)initialize {
	SInt32 majorVersionNumber;
	SInt32 minorVersionNumber;
	
	Gestalt(gestaltSystemVersionMajor, &majorVersionNumber);
	Gestalt(gestaltSystemVersionMinor, &minorVersionNumber);
	
	if ((majorVersionNumber == 10 && minorVersionNumber >= 7) || majorVersionNumber >= 11) {
		isRunningLionOrNewer = YES;
	} else {
		isRunningLionOrNewer = NO;
	}
}

+ (BOOL)isRunningLionOrNewer {
	return isRunningLionOrNewer;
}

@end
