//
//  ECDatabaseUpdateOperation.m
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECDatabaseUpdateOperation.h"
#import "ECDatabaseController.h"
#import "FMDatabase.h"

@implementation ECDatabaseUpdateOperation

@synthesize queries;

- (void)dealloc {
	[queries release];
	
	[super dealloc];
}

- (void)main {
	
	@try {
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		[ECDatabaseController updateDatabaseForQueries:queries];
        
		[self performSelectorOnMainThread:@selector(dispatchDidFinishDelegateMessage) withObject:nil waitUntilDone:YES];
		
		[pool drain];
		
	} @catch(...) {
		// Do not rethrow exceptions.
	}
}

@end
