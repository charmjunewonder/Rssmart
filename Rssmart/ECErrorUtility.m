//
//  ECErrorUtility.m
//  Rssmart
//
//  Created by charmjunewonder on 4/26/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECErrorUtility.h"

@implementation ECErrorUtility

+ (void)createAndDisplayError:(NSString *)message {
	NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
	[errorDetail setValue:message forKey:NSLocalizedDescriptionKey];
	NSError *error = [NSError errorWithDomain:@"ECDomain" code:0 userInfo:errorDetail];
	[NSApp presentError:error];
}

@end
