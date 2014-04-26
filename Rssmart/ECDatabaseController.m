//
//  ECDatabaseController.m
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECDatabaseController.h"
#import "FMDatabase.h"
#import "NSFileManager+ECAdditions.h"
#import "ECErrorUtility.h"
#import "ECSubscriptionFeed.h"
#import "ECSubscriptionFolder.h"
#import "ECConstants.h"

@interface ECDatabaseController (Private)
+ (NSString *)pathForDatabaseFile;
@end

@implementation ECDatabaseController
static NSString *path;
+ (NSString *)pathForDatabaseFile {
	
	if (path == nil) {
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *folder = [fileManager ecRssmartSupportDirectory];
		NSString *fileName = @"RssmartDatabase.db";
		
		path = [[folder stringByAppendingPathComponent:fileName] retain];
	}
	
	return path;
}

+ (BOOL)tableExists:(NSString *)tableName inDb:(FMDatabase *)db {
	BOOL returnBool;
	tableName = [tableName lowercaseString];
	
	FMResultSet *rs = [db executeQuery:@"select [sql] from sqlite_master where [type] = 'table' and lower(name) = ?", tableName];
	returnBool = [rs next];
	[rs close];
	
	return returnBool;
}

/*
 * create the table in the database or load the feeds from database
 */
+ (void)loadFromDatabaseTo:(ECSubscriptionItem *)subscriptions {
	
	FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
	
	if (![db open]) {
		[NSException raise:@"Database error" format:@"Failed to connect to the database!"];
	}
		
	if ([self tableExists:@"enclosure" inDb:db] == NO) {
		[db executeUpdate:@"CREATE TABLE enclosure (Id INTEGER PRIMARY KEY, PostId INTEGER, Url TEXT)"];
	}
	
	if ([self tableExists:@"feed" inDb:db] == NO) {
		[db executeUpdate:@"CREATE TABLE feed (Id INTEGER PRIMARY KEY, FolderId INTEGER, Url TEXT, Title TEXT, Icon BLOB, LastRefreshed REAL, IconLastRefreshed REAL, WebsiteLink TEXT, IsHidden INTEGER NOT NULL DEFAULT 0, UnreadCount INTEGER NOT NULL DEFAULT 0, LastSyncPosts BLOB)"];
	}
	
	if ([self tableExists:@"folder" inDb:db] == NO) {
		[db executeUpdate:@"CREATE TABLE folder (Id INTEGER PRIMARY KEY, ParentId INTEGER, Path TEXT, Title TEXT)"];
	}
	
	if ([self tableExists:@"miscellaneous" inDb:db] == NO) {
		[db executeUpdate:@"CREATE TABLE miscellaneous (Id INTEGER PRIMARY KEY, Key TEXT, Value TEXT)"];
	}
	
	if ([self tableExists:@"post" inDb:db] == NO) {
		[db executeUpdate:@"CREATE TABLE post (Id INTEGER PRIMARY KEY, FeedId INTEGER, Guid TEXT, Title TEXT, Link TEXT, Published INTEGER, Received INTEGER, Author TEXT, Content TEXT, PlainTextContent TEXT, IsRead INTEGER NOT NULL DEFAULT 0, HasEnclosures INTEGER NOT NULL DEFAULT 0, IsHidden INTEGER NOT NULL DEFAULT 0, IsStarred INTEGER NOT NULL DEFAULT 0)"];
	}
	
	[self recursivelyLoadChildrenOf:nil usingDatabaseHandle:db to:subscriptions];
	[db close];
	
//	NSString *versionId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//	[SyndicationAppDelegate miscellaneousSetValue:versionId forKey:MISCELLANEOUS_DATABASE_VERSION];
}

/*
 * load the folder and feed recursily from database
 * TODO:can be faster
 */
+ (void)recursivelyLoadChildrenOf:(ECSubscriptionFolder *)parentFolder
              usingDatabaseHandle:(FMDatabase *)db
                               to:(ECSubscriptionItem *)root
{
	
	FMResultSet *rs;
	if (parentFolder == nil) {
		rs = [db executeQuery:@"SELECT * FROM folder WHERE folder.ParentId IS NULL"];
	} else {
		rs = [db executeQuery:@"SELECT * FROM folder WHERE folder.ParentId=?", [NSNumber numberWithInteger:[parentFolder dbId]]];
	}
	
	while ([rs next]) {
		ECSubscriptionFolder *newFolder = [[ECSubscriptionFolder alloc] init];
        
		[newFolder setDbId:[rs longForColumn:@"Id"]];
		[newFolder setPath:[rs stringForColumn:@"Path"]];
		[newFolder setTitle:[rs stringForColumn:@"Title"]];
		
		if (parentFolder == nil) {
			[[root children] addObject:newFolder];
            //TODO:setParentFolderReference
		} else {
			[[parentFolder children] addObject:newFolder];
			[newFolder setParentFolderReference:parentFolder];
		}
		
		[self recursivelyLoadChildrenOf:newFolder usingDatabaseHandle:db to:nil];
		[newFolder release];
	}
	
	[rs close];
	rs = nil;
	
	if (parentFolder == nil) {
		rs = [db executeQuery:@"SELECT * FROM feed WHERE feed.FolderId IS NULL"];
	} else {
		rs = [db executeQuery:@"SELECT * FROM feed WHERE feed.FolderId=?", [NSNumber numberWithInteger:[parentFolder dbId]]];
	}
	
	while ([rs next]) {
		ECSubscriptionFeed *feed = [[ECSubscriptionFeed alloc] initWithResultSet:rs];
		
		BOOL isHidden = [rs boolForColumn:@"IsHidden"];
		
		if (isHidden == NO) {
			
            if (parentFolder == nil) {
                [[root children] addObject:feed];
                //TODO:setParentFolderReference
            } else {
                [[parentFolder children] addObject:feed];
                [feed setParentFolderReference:parentFolder];
            }

			
		}
		
//		[feedLookupDict setObject:feed forKey:[NSNumber numberWithInteger:[feed dbId]]];
		
		[feed release];
	}
	
	[rs close];
}

+ (void)addSubscriptionForUrlString:(NSString *)url toFolder:(ECSubscriptionFolder *)folder refreshImmediately:(BOOL)shouldRefresh{
	
	// check to see if this feed already exists in the database
	FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
	
	if (![db open]) {
		[ECErrorUtility createAndDisplayError:@"Unable to add subscription!"];
		return;
	}
	
	FMResultSet *rs = [db executeQuery:@"SELECT * FROM feed WHERE Url=? AND IsHidden=0", url];
	
	if ([rs next]) {
		[ECErrorUtility createAndDisplayError:@"The subscription could not be added because it already exists in your library!"];
		[rs close];
		[db close];
		return;
	}
	
	[rs close];
    
    //put the new feed into database
	NSNumber *folderId = nil;
	NSInteger rowId = 0;
	NSString *feedTitle = nil;
    
//	if (folder != nil) {
//		folderId = [NSNumber numberWithInteger:[folder dbId]];
//	}
		
	[db executeUpdate:@"INSERT INTO feed (FolderId, Url, Title) VALUES (?, ?, ?)", folderId, url, feedTitle];
	
	rowId = [db lastInsertRowId];
	
	[db close];
	
	
}

@end
