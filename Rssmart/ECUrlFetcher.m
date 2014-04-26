//
//  ECUrlFetcher.m
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECUrlFetcher.h"
#import "ECConstants.h"

@implementation ECUrlFetcher

+ (NSData *)fetchUrlString:(NSString *)urlString postData:(NSData *)postData returnNilOnFailure:(BOOL)nilOnFail urlResponse:(NSURLResponse **)urlResponse {
	
	NSURL *fetchUrl = [NSURL URLWithString:urlString];
	
	if (fetchUrl == nil) {
		return nil;
	}
	
	NSMutableURLRequest *fetchUrlRequest = [NSMutableURLRequest requestWithURL:fetchUrl
																   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
															   timeoutInterval:URL_REQUEST_TIMEOUT];
	
	[fetchUrlRequest setHTTPShouldHandleCookies:NO];
	
	if (postData != nil) {
		[fetchUrlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[fetchUrlRequest setValue:[NSString stringWithFormat:@"%ld", [postData length]] forHTTPHeaderField:@"Content-Length"];
		[fetchUrlRequest setHTTPMethod:@"POST"];
		[fetchUrlRequest setHTTPBody:postData];
	} else {
		[fetchUrlRequest setHTTPMethod:@"GET"];
	}
	
	NSData *fetchData = nil;
	NSURLResponse *fetchUrlResponse = nil;
	NSError *fetchError = nil;
	BOOL tryAgain = NO;
	
	do {
		fetchData = nil;
		fetchUrlResponse = nil;
		fetchError = nil;
		
		fetchData = [NSURLConnection sendSynchronousRequest:fetchUrlRequest returningResponse:&fetchUrlResponse error:&fetchError];
		tryAgain = NO;
		
		// keep trying if connection is offline
		if (fetchData == nil && fetchError != nil && [fetchError code] == -1009) {
			[NSThread sleepForTimeInterval:OFFLINE_RETRY_PAUSE];
			
			fetchData = nil;
			fetchUrlResponse = nil;
			fetchError = nil;
			
			tryAgain = YES;
		}
		
	} while (tryAgain);
	
	if (urlResponse != nil) {
		*urlResponse = fetchUrlResponse;
	}
	
	[[NSURLCache sharedURLCache] removeCachedResponseForRequest:fetchUrlRequest];
	
	if ([fetchUrlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
		if ([ECUrlFetcher isSuccessStatusCode:[(NSHTTPURLResponse *)fetchUrlResponse statusCode]] == NO) {
			if (nilOnFail) {
				return nil;
			}
		}
	}
	
	return fetchData;
}

+ (NSURLConnection *)fetchUrlString:(NSString *)urlString delegate:(id)delegate {
	
	NSURL *fetchUrl = [NSURL URLWithString:urlString];
	
	if (fetchUrl == nil) {
		return nil;
	}
	
	NSMutableURLRequest *fetchUrlRequest = [NSMutableURLRequest requestWithURL:fetchUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:URL_REQUEST_TIMEOUT];
	[fetchUrlRequest setHTTPShouldHandleCookies:NO];
	[fetchUrlRequest setHTTPMethod:@"GET"];
	
	NSURLConnection *fetchUrlConnection = [[[NSURLConnection alloc] initWithRequest:fetchUrlRequest delegate:delegate startImmediately:YES] autorelease];
	
	return fetchUrlConnection;
}

+ (BOOL)isSuccessStatusCode:(NSInteger)code {
	if (code >= 200 && code < 300) {
		return YES;
	}
	
	return NO;
}

@end
