//
//  NSString+ECAddition.h
//  Rssmart
//
//  Created by charmjunewonder on 4/26/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//


@interface NSString(ECAddition)

- (NSString *)ecTrimmedString;
- (NSString *)ecUrlEncodedParameterString;
- (NSString *)ecEscapeXMLString;
- (NSString *)ecUnescapeXMLString;

@end
