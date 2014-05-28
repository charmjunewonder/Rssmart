//
//  ECHTMLFilter.m
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECHTMLFilter.h"
#import <WebKit/WebKit.h>
#import "ECConstants.h"
#import "NSString+ECAdditions.h"
@implementation ECHTMLFilter

# pragma mark convenience & helper methods

+ (NSString *)extractPlainTextFromString:(NSString *)htmlString {
	
	NSString *plainTextString;
	
	if (htmlString == nil || [htmlString length] == 0) {
		return @"";
	}
	
	NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithXMLString:htmlString options:NSXMLDocumentTidyHTML error:nil];
	
	if (xmlDocument == nil) {
		return @"";
	}
	
	plainTextString = [ECHTMLFilter extractPlainTextFromNode:xmlDocument];
	
	[xmlDocument release];
	
	if (plainTextString != nil) {
		plainTextString = [plainTextString ecTrimmedString];
	}
	
	return plainTextString;
}

+ (NSString *)extractPlainTextFromNode:(NSXMLNode *)node {
	NSMutableString *returnValue = [NSMutableString string];
	
	if ([node kind] == NSXMLTextKind) {
		[returnValue appendString:[node stringValue]];
	} else if ([node kind] == NSXMLElementKind || [node kind] == NSXMLDocumentKind) {
		if ([[node name] isEqual:@"script"] == NO && [[node name] isEqual:@"style"] == NO) {
			for (NSXMLNode *child in [node children]) {
				[returnValue appendString:[ECHTMLFilter extractPlainTextFromNode:child]];
			}
		}
	}
	
	return returnValue;
}

+ (NSString *)extractFirstImageUrlFromString:(NSString *)htmlString {
	
	NSString *firstImageUrl;
	
	if (htmlString == nil || [htmlString length] == 0) {
		return @"";
	}
	
    NSRange t = [htmlString rangeOfString:@"<img "];
    
    if(t.location == NSNotFound){
        return nil;
    }

    htmlString = [htmlString substringFromIndex:t.location + t.length];
    
    NSRange m = [htmlString rangeOfString:@"src=\""];
    
    htmlString = [htmlString substringFromIndex:m.location + m.length];

    NSRange d = [htmlString rangeOfString:@"\""];
    firstImageUrl = [htmlString substringToIndex:d.location];

	if ([firstImageUrl hasPrefix:@"//"] ) {
        firstImageUrl = [NSString stringWithFormat:@"http:%@", firstImageUrl];
    }
	return firstImageUrl;
}

+ (NSString *)extractFirstImageUrlFromNode:(NSXMLNode *)node {
	NSMutableString *returnValue = [NSMutableString string];
	
	if ([node kind] == NSXMLTextKind) {
		[returnValue appendString:[node stringValue]];
	} else if ([node kind] == NSXMLElementKind || [node kind] == NSXMLDocumentKind) {
        NSLog(@"%@", [node name]);
		if ([[node name] isEqual:@"script"] == NO && [[node name] isEqual:@"style"] == NO) {
			for (NSXMLNode *child in [node children]) {
				[returnValue appendString:[ECHTMLFilter extractFirstImageUrlFromNode:child]];
			}
		}
	}
	
	return returnValue;
}

+ (NSString *)cleanUrlString:(NSString *)urlString {
	
	if (urlString == nil || [urlString isEqual:@""]) {
		return urlString;
	}
	
	urlString = [urlString ecTrimmedString];
	
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:@"SyndicationPB"];
	[pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
	
	@try {
		if ([pasteboard setString:urlString forType:NSStringPboardType]) {
			NSURL *urlToLoad = [WebView URLFromPasteboard:pasteboard];
			urlString = [urlToLoad absoluteString];
		}
	} @catch (...) {
		urlString = @"";
	}
	
	return urlString;
}

@end
