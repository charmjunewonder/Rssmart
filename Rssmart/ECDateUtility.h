//
//  ECDateUtility.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

typedef enum {ECDateFormatHintNone, ECDateFormatHintRFC822, ECDateFormatHintRFC3339} ECDateFormatHint;

@interface ECDateUtility : NSObject

+ (NSDate *)dateFromInternetDateTimeString:(NSString *)dateString formatHint:(ECDateFormatHint)hint;
+ (NSDate *)dateFromRFC3339String:(NSString *)dateString;
+ (NSDate *)dateFromRFC822String:(NSString *)dateString;
+ (NSTimeInterval)timeIntervalUntilMidnight;

@end
