//
//  ECIconRefreshOperation.m
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECConstants.h"
#import "ECIconRefreshOperation.h"
#import "ECSubscriptionFeed.h"
#import "ECUrlFetcher.h"
#import "FMDatabase.h"

@implementation ECIconRefreshOperation

@synthesize delegate;
@synthesize feed;
@synthesize favicon;

- (void)dealloc {
	[feed release];
	[favicon release];
	
	[super dealloc];
}

- (void)main {
	
	@try {
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		[self performSelectorOnMainThread:@selector(dispatchDidStartDelegateMessage) withObject:nil waitUntilDone:YES];
		
		if (feed == nil || [feed websiteLink] == nil || [[feed websiteLink] length] == 0) {
			[self performSelectorOnMainThread:@selector(dispatchDidFinishDelegateMessage) withObject:nil waitUntilDone:YES];
			[pool drain];
			return;
		}
		
		if ([feed websiteLink] != nil && [[feed websiteLink] length] > 0) {
			[self setFavicon:[self faviconForUrlString:[feed websiteLink]]];
		}
		
		[self performSelectorOnMainThread:@selector(dispatchIconRefreshDelegateMessage) withObject:nil waitUntilDone:YES];
		
		[self performSelectorOnMainThread:@selector(dispatchDidFinishDelegateMessage) withObject:nil waitUntilDone:YES];
		
		[pool drain];
		
	} @catch(...) {
		// Do not rethrow exceptions.
	}
}

- (NSImage *)faviconForUrlString:(NSString *)urlString {
	NSString *faviconPath = nil;
	NSData *faviconData = nil;
	NSImage *faviconImage = nil;
	NSURLResponse *faviconUrlResponse;
	NSURL *faviconurl = [NSURL URLWithString:urlString];
	//NSDictionary *faviconHeaders = nil;
	//NSString *faviconContentType = nil;
	
	if (faviconurl != nil && [[faviconurl host] length] > 0) {
		
		faviconPath = [NSString stringWithFormat:@"http://%@/favicon.ico", [faviconurl host]];
		faviconData = [ECUrlFetcher fetchUrlString:faviconPath postData:nil returnNilOnFailure:YES urlResponse:&faviconUrlResponse];
		
		if (faviconData != nil) {
			faviconImage = [[[NSImage alloc] initWithDataIgnoringOrientation:faviconData] autorelease];
		}
		
		if (faviconImage == nil) {
			NSString *fullHost = [faviconurl host];
			
			// check for a subdomain
			NSArray *hostParts = [fullHost componentsSeparatedByString:@"."];
			
			// we want to match something like mail.foobar.com and not things like johnsmith.co.uk
			if ([hostParts count] > 2 && [[hostParts objectAtIndex:1] length] > 2) {
				NSString *newHost = [NSString stringWithFormat:@"%@.%@", [hostParts objectAtIndex:1], [hostParts objectAtIndex:2]];
				faviconPath = [NSString stringWithFormat:@"http://%@/favicon.ico", newHost];
				faviconData = [ECUrlFetcher fetchUrlString:faviconPath postData:nil returnNilOnFailure:YES urlResponse:&faviconUrlResponse];
				
				if (faviconData != nil) {
					faviconImage = [[[NSImage alloc] initWithDataIgnoringOrientation:faviconData] autorelease];
				}
			}
		}
	}
	
	return faviconImage;
}

- (void)dispatchIconRefreshDelegateMessage {
	if ([NSThread isMainThread] == NO) {
		[NSException raise:@"Thread error" format:@"This function should only be called from the main thread!"];
	}
	
	[delegate iconRefreshOperation:self refreshedFeed:feed foundIcon:favicon];
}

@end
