//
//  ECTimer.m
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECTimer.h"
#import "ECConstants.h"
#import <QuartzCore/QuartzCore.h>

@implementation ECTimer

@synthesize timer;
@synthesize timeInterval;
@synthesize target;
@synthesize selector;
@synthesize userInfo;
@synthesize repeats;
@synthesize startTime;
@synthesize sleepDate;

- (void)dealloc {
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[timer release];
	[sleepDate release];
	
	[super dealloc];
}

+ (ECTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)aTimeInterval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)aUserInfo repeats:(BOOL)aRepeats {
	ECTimer *newTimer = [[[ECTimer alloc] init] autorelease];
	[newTimer setTimeInterval:aTimeInterval];
	[newTimer setTarget:aTarget];
	[newTimer setSelector:aSelector];
	[newTimer setUserInfo:aUserInfo];
	[newTimer setRepeats:aRepeats];
	[newTimer setStartTime:CACurrentMediaTime()];
	
	NSTimer *realTimer = [NSTimer scheduledTimerWithTimeInterval:aTimeInterval target:newTimer selector:@selector(realTimerFired:) userInfo:nil repeats:aRepeats];
	[newTimer setTimer:realTimer];
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:newTimer selector:@selector(willSleep:) name:NSWorkspaceWillSleepNotification object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:newTimer selector:@selector(didWake:) name:NSWorkspaceDidWakeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:newTimer selector:@selector(clockDidChange:) name:NSSystemClockDidChangeNotification object:nil];
	
	return newTimer;
}

- (void)invalidate {
	[timer invalidate];
	[self setTimer:nil];
}

- (BOOL)isValid {
	return [timer isValid];
}

- (void)realTimerFired:(NSTimer *)realTimer {
	if (target != nil && selector != nil) {
		if ([target respondsToSelector:selector]) {
			[target performSelector:selector withObject:self];
		}
	}
	
	if ([self repeats] == NO) {
		[self setTimer:nil];
	}
}

- (void)willSleep:(NSNotification *)notification {
	if ([self isValid]) {
		[self setSleepDate:[NSDate date]];
	}
}

- (void)didWake:(NSNotification *)notification {
	if ([self isValid]) {
		if (sleepDate == nil) {
			return;
		}
		
		NSDate *wakeDate = [NSDate date];
		double currentTime = CACurrentMediaTime();
		NSTimeInterval sleepLength = [wakeDate timeIntervalSinceDate:sleepDate];
		NSTimeInterval adjustedTimeInterval = (timeInterval - (currentTime - startTime)) - sleepLength;
		
		NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:adjustedTimeInterval];
		[timer setFireDate:fireDate];
		
		[self setSleepDate:nil];
	}
}

- (void)clockDidChange:(NSNotification *)notification {
	if ([self isValid]) {
		double currentTime = CACurrentMediaTime();
		NSTimeInterval adjustedTimeInterval = timeInterval - (currentTime - startTime);
		NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:adjustedTimeInterval];
		[timer setFireDate:fireDate];
	}
}

@end
