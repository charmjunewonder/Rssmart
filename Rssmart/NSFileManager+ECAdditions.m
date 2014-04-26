//
//  NSFileManager+ECAdditions.m
//  Rssmart
//
//  Created by charmjunewonder on 4/26/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "NSFileManager+ECAdditions.h"
#import "ECConstants.h"

@implementation NSFileManager (ECAdditions)

- (NSString *)ecApplicationSupportDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	
	if ([paths count] == 0)	{
		return nil;
	}
	
	// only need the first path returned
	NSString *resolvedPath = [paths objectAtIndex:0];
	
	return resolvedPath;
}

- (NSString *)ecRssmartSupportDirectory {
	NSString *supportDirectory = [self ecApplicationSupportDirectory];
	NSString *executableName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
	NSString *syndicationSupportDirectory = [supportDirectory stringByAppendingPathComponent:executableName];
	
	BOOL isDirectory = NO;
	BOOL exists = [self fileExistsAtPath:syndicationSupportDirectory isDirectory:&isDirectory];
	
    if (exists && !isDirectory) {
        return nil;
    }
    
	if (!exists) {
		BOOL success = [self createDirectoryAtPath:syndicationSupportDirectory withIntermediateDirectories:YES attributes:nil error:nil];
		if (!success) {
			return nil;
		}
	}
	
	return syndicationSupportDirectory;
}

- (void)ecCopyLiteDirectoryIfItExistsAndRegularDirectoryDoesnt {
    NSString *supportDirectory = [self ecApplicationSupportDirectory];
	NSString *executableName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
	
	// if this accidently gets called from the Lite version itself, don't do anything
	if ([executableName hasSuffix:@"Lite"]) {
		return;
	}
	
	NSString *liteExecutableName = [executableName stringByAppendingString:@" Lite"];
	NSString *syndicationSupportDirectory = [supportDirectory stringByAppendingPathComponent:executableName];
	NSString *syndicationLiteSupportDirectory = [supportDirectory stringByAppendingPathComponent:liteExecutableName];
	
	BOOL liteIsDirectory = NO;
	BOOL liteExists = [self fileExistsAtPath:syndicationLiteSupportDirectory isDirectory:&liteIsDirectory];
	BOOL regularExists = [self fileExistsAtPath:syndicationSupportDirectory];
	
	if (liteExists && liteIsDirectory && !regularExists) {
		[self copyItemAtPath:syndicationLiteSupportDirectory toPath:syndicationSupportDirectory error:nil];
	}
}

@end
