//
//  NSString+ECAddition.m
//  Rssmart
//
//  Created by charmjunewonder on 4/26/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "NSString+ECAdditions.h"

@implementation NSString (ECAdditions)

- (NSString *)ecTrimmedString {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)ecUrlEncodedParameterString {
	NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, CFSTR("!*'\"();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
	return [encodedString autorelease];
}

- (NSString *)ecEscapeXMLString {
	NSString *escapedString = (NSString *)CFXMLCreateStringByEscapingEntities(NULL, (CFStringRef)self, NULL);
	return [escapedString autorelease];
}

- (NSString *)ecUnescapeXMLString {
	NSString *unescapedString = (NSString *)CFXMLCreateStringByUnescapingEntities(NULL, (CFStringRef)self, NULL);
	return [unescapedString autorelease];
}

@end
