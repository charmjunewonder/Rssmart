//
//  ECPostTest.m
//  Rssmart
//
//  Created by charmjunewonder on 5/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FMDatabase.h"
#import "ECDatabaseController.h"
#import "NSFileManager+ECAdditions.h"

@interface ECPostTest : XCTestCase

@end

@implementation ECPostTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folder = [fileManager ecRssmartSupportDirectory];
    NSString *fileName = @"RssmartDatabase.db";
    
    NSString *path = [folder stringByAppendingPathComponent:fileName];

    FMDatabase *db = [FMDatabase databaseWithPath:path];
	
	if (![db open]) {
		[NSException raise:@"Database error" format:@"Failed to connect to the database!"];
	}
	
	NSString *dbQuery = @"SELECT post.* FROM post LIMIT 1";
	
	FMResultSet *rs = [db executeQuery:dbQuery];
    XCTAssertTrue(rs.next, @"no row in the table");
}

@end
