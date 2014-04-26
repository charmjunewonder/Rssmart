//
//  ECTimer.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//


@interface ECTimer : NSObject

@property (retain, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSTimeInterval timeInterval;
@property (assign, nonatomic) id target;
@property (assign, nonatomic) SEL selector;
@property (assign, nonatomic) id userInfo;
@property (assign, nonatomic) BOOL repeats;
@property (assign, nonatomic) double startTime;
@property (retain, nonatomic) NSDate *sleepDate;

+ (ECTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)aTimeInterval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)aUserInfo repeats:(BOOL)aRepeats;

- (void)invalidate;
- (BOOL)isValid;
- (void)realTimerFired:(NSTimer *)realTimer;
- (void)willSleep:(NSNotification *)notification;
- (void)didWake:(NSNotification *)notification;
- (void)clockDidChange:(NSNotification *)notification;


@end
