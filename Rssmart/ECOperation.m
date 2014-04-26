//
//  ECOperation.m
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECConstants.h"
#import "ECOperation.h"

@implementation ECOperation

@synthesize _delegate;

- (id <ECOperationDelegate>)delegate {
	return _delegate;
}

- (void)setDelegate:(id <ECOperationDelegate>)delegate {
	[self set_delegate:delegate];
}

- (void)dispatchDidStartDelegateMessage {
	if ([NSThread isMainThread] == NO) {
		[NSException raise:@"Thread error" format:@"This function should only be called from the main thread!"];
	}
	
	[[self delegate] didStartOperation:self];
}

- (void)dispatchDidFinishDelegateMessage {
	if ([NSThread isMainThread] == NO) {
		[NSException raise:@"Thread error" format:@"This function should only be called from the main thread!"];
	}
	
	[[self delegate] didFinishOperation:self];
}

@end
