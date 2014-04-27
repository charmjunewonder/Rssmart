//
//  ECFeedRequest.m
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECFeedRequest.h"
#import "ECConstants.h"
#import "ECSubscriptionFeed.h"
#import "ECTimer.h"
#import "ECUrlFetcher.h"

@implementation ECFeedRequest

@synthesize delegate;
@synthesize feed;
@synthesize urlConnection;
@synthesize urlResponse;
@synthesize receivedData;
@synthesize safetyTimer;

- (id)init {
	self = [super init];
	if (self != nil) {
		[self setReceivedData:[NSMutableData data]];
	}
	return self;
}

- (void)dealloc {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	if ([safetyTimer isValid]) {
		[safetyTimer invalidate];
	}
	
	[feed release];
	[urlConnection release];
	[urlResponse release];
	[receivedData release];
	[safetyTimer release];
	
	[super dealloc];
}

- (void)startConnection {
	if ([safetyTimer isValid]) {
		[safetyTimer invalidate];
		[self setSafetyTimer:nil];
	}
	
	[receivedData setLength:0];
	[self setUrlConnection:nil];
	[self setUrlResponse:nil];
	
	NSString *feedUrlString = [feed url];
	
	if (feedUrlString == nil) {
		[delegate feedRequest:self didFinishWithData:nil encoding:0];
		return;
	}
	
	if ([[feedUrlString substringToIndex:7] isEqual:@"feed://"]) {
		feedUrlString = [NSString stringWithFormat:@"http://%@", [feedUrlString substringFromIndex:7]];
	}
	
	NSURLConnection *conn = [ECUrlFetcher fetchUrlString:feedUrlString delegate:self];
	
	if (conn == nil) {
		[delegate feedRequest:self didFinishWithData:nil encoding:0];
		return;
	}
	
	[self setUrlConnection:conn];
	
	ECTimer *timer = [ECTimer scheduledTimerWithTimeInterval:(URL_REQUEST_TIMEOUT + 20) target:self selector:@selector(stopConnection) userInfo:nil repeats:NO];
	[self setSafetyTimer:timer];
}

- (void)stopConnection {
	[urlConnection cancel];
	
	if ([safetyTimer isValid]) {
		[safetyTimer invalidate];
		[self setSafetyTimer:nil];
	}
	
	[delegate feedRequest:self didFinishWithData:nil encoding:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self setUrlResponse:response];
	
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if ([error code] == -1009) {
		[self performSelector:@selector(startConnection) withObject:nil afterDelay:OFFLINE_RETRY_PAUSE];
		return;
	}
	
	if ([safetyTimer isValid]) {
		[safetyTimer invalidate];
		[self setSafetyTimer:nil];
	}
	
	[delegate feedRequest:self didFinishWithData:nil encoding:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ([safetyTimer isValid]) {
		[safetyTimer invalidate];
		[self setSafetyTimer:nil];
	}
	
	NSString *textEncodingName = [urlResponse textEncodingName];
	NSStringEncoding stringEncoding = NSUTF8StringEncoding;
	
	if (textEncodingName != nil) {
		CFStringEncoding cfStringEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)textEncodingName);
		stringEncoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding);
	}
	
	[delegate feedRequest:self didFinishWithData:receivedData encoding:stringEncoding];
}

@end
