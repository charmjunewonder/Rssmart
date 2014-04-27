//
//  ECStringHelper.m
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECStringHelper.h"
#import "ECConstants.h"

@implementation ECStringHelper

+ (NSString *)stringFromData:(NSData *)data withPossibleEncoding:(NSStringEncoding)stringEncoding {
	
	NSString *stringFromData = [[[NSString alloc] initWithData:data encoding:stringEncoding] autorelease];
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	// in case of failure, try other encodings
	if (stringEncoding != NSUTF8StringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSISOLatin1StringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSASCIIStringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSUnicodeStringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSJapaneseEUCStringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSJapaneseEUCStringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSShiftJISStringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSISOLatin2StringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSISOLatin2StringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSWindowsCP1251StringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSWindowsCP1251StringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSWindowsCP1252StringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSWindowsCP1252StringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSWindowsCP1253StringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSWindowsCP1253StringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSWindowsCP1254StringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSWindowsCP1254StringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSWindowsCP1250StringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSWindowsCP1250StringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSMacOSRomanStringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding] autorelease];
	}
	
	if (stringFromData != nil) {
		return stringFromData;
	}
	
	if (stringEncoding != NSUTF32StringEncoding) {
		stringFromData = [[[NSString alloc] initWithData:data encoding:NSUTF32StringEncoding] autorelease];
	}
	
	return stringFromData;
}

@end
