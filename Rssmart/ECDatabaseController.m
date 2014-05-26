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
#import "ECTimer.h"
#import "ECRequestController.h"
#import "ECSubscriptionsController.h"
#import "ECPost.h"

#define UNREAD_COUNT_QUERY @"UPDATE feed SET UnreadCount = (SELECT COUNT(Id) FROM post WHERE FeedId=? AND IsRead=0 AND IsHidden=0) WHERE Id=?"
#define SEARCH_QUERY @"SELECT post.*, feed.Title AS FeedTitle, feed.Url AS FeedUrlString FROM post, feed WHERE post.FeedId=feed.Id AND post.IsHidden=0 AND (%@)"
#define FEED_QUERY @"SELECT post.*, feed.Title AS FeedTitle, feed.Url AS FeedUrlString FROM post, feed WHERE post.FeedId=feed.Id AND feed.Id=%ld AND post.IsHidden=0"
#define FOLDER_QUERY @"SELECT post.*, feed.Title AS FeedTitle, feed.Url AS FeedUrlString FROM post, feed, folder WHERE post.FeedId=feed.Id AND feed.FolderId=folder.Id AND folder.Path LIKE '%@%%' AND post.IsHidden=0"
#define NEW_ITEMS_QUERY @"SELECT post.*, feed.Title AS FeedTitle, feed.Url AS FeedUrlString FROM post, feed WHERE post.FeedId=feed.Id AND post.IsHidden=0 AND post.IsRead=0"
#define STARRED_QUERY @"SELECT post.*, feed.Title AS FeedTitle, feed.Url AS FeedUrlString FROM post, feed WHERE post.FeedId=feed.Id AND post.IsHidden=0 AND post.IsStarred=1"

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
    
    if ([self tableExists:@"keyword" inDb:db] == NO) {
		[db executeUpdate:@"CREATE TABLE keyword (Id INTEGER PRIMARY KEY, keyword TEXT, weight DOUBLE DEFAULT 0.0)"];
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
		rs = [db executeQuery:@"SELECT * FROM feed WHERE feed.FolderId=?",[NSNumber numberWithInteger:0]
];
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
                [parentFolder setBadgeValue:[parentFolder badgeValue]+[feed badgeValue]];
                [feed setParentFolderReference:parentFolder];
            }
            
            ECRequestController *requestCon = [ECRequestController getSharedInstance];
            [requestCon startToRequestIconForFeed:feed];

		}
		[[[ECSubscriptionsController getSharedInstance] feedLookupDict] setObject:feed forKey:[NSNumber numberWithInteger:[feed dbId]]];
		
		[feed release];
	}
	
	[rs close];
}

//
+ (ECSubscriptionFeed *)addSubscriptionForUrlString:(NSString *)url toFolder:(ECSubscriptionFolder *)folder refreshImmediately:(BOOL)shouldRefresh{
	
	// check to see if this feed already exists in the database
	FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
	
	if (![db open]) {
		[ECErrorUtility createAndDisplayError:@"Unable to add subscription!"];
		return nil;
	}
	
	FMResultSet *rs = [db executeQuery:@"SELECT * FROM feed WHERE Url=? AND IsHidden=0", url];
	
	if ([rs next]) {
		[ECErrorUtility createAndDisplayError:@"The subscription could not be added because it already exists in your library!"];
		[rs close];
		[db close];
		return nil;
	}
	
	[rs close];
    
    //put the new feed into database
	NSNumber *folderId = nil;
	NSInteger rowId = 0;
	NSString *feedTitle = nil;
    BOOL hasHiddenEquivalent = NO;

	if (folder != nil) {
		folderId = [NSNumber numberWithInteger:[folder dbId]];
	}
    
    if (folderId == nil) {
        folderId = [NSNumber numberWithInteger:0];
    }
		
	[db executeUpdate:@"INSERT INTO feed (FolderId, Url, Title) VALUES (?, ?, ?)", folderId, url, feedTitle];
	
	rowId = [db lastInsertRowId];
	
	[db close];
	
    //put the new feed into subscriptionList
	ECSubscriptionFeed *newSub = nil;
	
	if (hasHiddenEquivalent) {
//		newSub = [self feedForDbId:rowId];
	} else {
		newSub = [[[ECSubscriptionFeed alloc] init] autorelease];
	}
	
	[newSub setTitle:feedTitle];
	[newSub setDbId:rowId];
	[newSub setUrl:url];
	
//	if (hasHiddenEquivalent == NO) {
//		[feedLookupDict setObject:newSub forKey:[NSNumber numberWithInteger:[newSub dbId]]];
//	}
	ECSubscriptionsController *subsCon = [ECSubscriptionsController getSharedInstance];
	if (folder != nil) {
        [newSub setParentFolderReference:folder];
		[[folder children] addObject:newSub];
	} else {
//TODO:		[subscriptionList addObject:newSub];
        [[[subsCon subscriptionSubscriptions] children] addObject:newSub];
	}
	
//	[self sortSourceList];
    [subsCon refreshSubscriptionsView];
	
	if (shouldRefresh) {
		[[ECRequestController getSharedInstance] queueSyncRequestForSpecificFeeds:[NSMutableArray arrayWithObject:newSub]];
	}
    return newSub;
}

+ (NSMutableArray *)checkIfPostsNotExists:(NSMutableArray *)probablyNewPosts{
	FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
    
    NSMutableArray *newPosts = [NSMutableArray array];
    
    if (![db open]) {
        [NSException raise:@"Database error" format:@"Failed to connect to the database!"];
    }
    
    for (ECPost *post in probablyNewPosts) {
        BOOL postIsNew = YES;
        
        FMResultSet *rs = nil;
        
        if ([post title] != nil && [[post title] length] > 0 && [post plainTextContent] != nil && [[post plainTextContent] length] > 0) {
            rs = [db executeQuery:@"SELECT * FROM post WHERE FeedId=? AND Title=? AND PlainTextContent=?", [NSNumber numberWithInteger:[post feedDbId]], [post title], [post plainTextContent]];
            
            if ([db hadError] || [rs next]) {
                postIsNew = NO;
            }
            
            [rs close];
        } else if ([post title] != nil && [[post title] length] > 0 && ([post plainTextContent] == nil || [[post plainTextContent] length] == 0)) {
            rs = [db executeQuery:@"SELECT * FROM post WHERE FeedId=? AND Title=? AND PlainTextContent IS NULL", [NSNumber numberWithInteger:[post feedDbId]], [post title]];
            
            if ([db hadError] || [rs next]) {
                postIsNew = NO;
            }
            
            [rs close];
        } else if ([post plainTextContent] != nil && [[post plainTextContent] length] > 0 && ([post title] == nil || [[post title] length] == 0)) {
            rs = [db executeQuery:@"SELECT * FROM post WHERE FeedId=? AND Title IS NULL AND PlainTextContent=?", [NSNumber numberWithInteger:[post feedDbId]], [post plainTextContent]];
            
            if ([db hadError] || [rs next]) {
                postIsNew = NO;
            }
            
            [rs close];
        }
        
        // if we still think this post is new, check the guid
        if (postIsNew && [post guid] != nil && [[post guid] length] > 0) {
            rs = [db executeQuery:@"SELECT * FROM post WHERE FeedId=? AND Guid=?", [NSNumber numberWithInteger:[post feedDbId]], [post guid]];
            
            if ([db hadError] || [rs next]) {
                postIsNew = NO;
            }
            
            [rs close];
        }
        
        if (postIsNew) {
            [newPosts addObject:post];
        }
    }
    
    [db close];
    return newPosts;
}

+ (void)updateLastSyncPosts:(NSArray *)syncPosts forFeed:(ECSubscriptionFeed *)feed{
    FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
    
    if (![db open]) {
        [NSException raise:@"Database error" format:@"Failed to connect to the database!"];
    }
    
    NSData *syncPostsData = [NSArchiver archivedDataWithRootObject:syncPosts];
    [db executeUpdate:@"UPDATE feed SET LastSyncPosts=? WHERE Id=?", syncPostsData, [NSNumber numberWithInteger:[feed dbId]]];
    
    [db close];

}

+ (void)updateWebsiteLink:(NSString *)webLink forFeed:(ECSubscriptionFeed *)feed{
    FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
    
    if (![db open]) {
        [NSException raise:@"Database error" format:@"Failed to connect to the database!"];
    }
    
    [db executeUpdate:@"UPDATE feed SET WebsiteLink=? WHERE Id=?", webLink, [NSNumber numberWithInteger:[feed dbId]]];
    
    [db close];

}

+ (void)addToDatabaseForPosts:(NSMutableArray *)posts forFeed:(ECSubscriptionFeed *)feed{
    FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
    
    if (![db open]) {
        [NSException raise:@"Database error" format:@"Failed to connect to the database!"];
    }
    
    BOOL feedStillExistsInDatabase = NO;
    BOOL isHiddenFeed = NO;
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM feed WHERE Id=?", [NSNumber numberWithInteger:[feed dbId]]];
    
    if ([rs next]) {
        feedStillExistsInDatabase = YES;
        isHiddenFeed = [rs boolForColumn:@"IsHidden"];
    }
    
    [rs close];
    [db close];
    
    if (feedStillExistsInDatabase) {
        
        db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
        
        if (![db open]) {
            [NSException raise:@"Database error" format:@"Failed to connect to the database!"];
        }
        
        NSDate *now;
        
        [db beginTransaction];
        
        for (ECPost *post in posts) {
            
            now = [NSDate date];
            
            if ([post published] == nil) {
                [post setPublished:now];
            }
            
            [post setReceived:now];
            
            BOOL hasEnclosures = NO;
            
            if ([[post enclosures] count] > 0) {
                hasEnclosures = YES;
            }
            
            [db executeUpdate:@"INSERT INTO post (FeedId, Guid, Title, Link, Published, Received, Author, Content, PlainTextContent, IsRead, HasEnclosures) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [NSNumber numberWithInteger:[post feedDbId]], [post guid], [post title], [post link], [post published], [post received], [post author], [post content], [post plainTextContent], [NSNumber numberWithBool:[post isRead]], [NSNumber numberWithBool:hasEnclosures]];
            NSInteger insertId = [db lastInsertRowId];
            [post setDbId:insertId];
            
            for (NSString *enclosure in [post enclosures]) {
                [db executeUpdate:@"INSERT INTO enclosure (PostId, Url) VALUES (?, ?)", [NSNumber numberWithInteger:insertId], enclosure];
            }
        }
        
        [[ECRequestController getSharedInstance] runDatabaseUpdateOnBackgroundThread:UNREAD_COUNT_QUERY, [NSNumber numberWithInteger:[feed dbId]], [NSNumber numberWithInteger:[feed dbId]], nil];
        
        [db commit];
        
        [db close];
        if (isHiddenFeed == NO) {
//            [self addPostsToAllWindows:reverseNewItems forFeed:feed orNewItems:YES orStarredItems:NO];
        }
    }
}

+ (void)updateDatabaseForQueries:(NSArray *)queries{
    FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
    
    if (![db open]) {
        [NSException raise:@"Database error" format:@"Failed to connect to the database!"];
    }
    
    [db beginTransaction];
    
    for (NSArray *query in queries) {
        NSString *queryString = [query objectAtIndex:0];
        NSArray *parameters = nil;
        
        if ([query count] > 1) {
            parameters = [query subarrayWithRange:NSMakeRange(1, [query count] - 1)];
        }
        
        [db executeUpdate:queryString withArgumentsInArray:parameters];
    }
    
    [db commit];
    
    [db close];

}

+ (ECSubscriptionFolder *)addFolderWithTitle:(NSString *)title{
    FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
	
	if (![db open]) {
		[NSException raise:@"Database error" format:@"Failed to connect to the database!"];
	}
	
	NSNumber *parentId = nil;
		
	[db executeUpdate:@"INSERT INTO folder (ParentId, Title) VALUES (?, ?)", parentId, title];
	
	NSInteger insertId = [db lastInsertRowId];
	NSMutableString *folderPath = [NSMutableString string];
		
	[folderPath appendFormat:@"%ld/", insertId];
	
	[db executeUpdate:@"UPDATE folder SET Path=? WHERE Id=?", folderPath, [NSNumber numberWithInteger:insertId]];
	
	[db close];
    
    ECSubscriptionFolder *folder = [[[ECSubscriptionFolder alloc] init] autorelease];
    
	[folder setTitle:title];
	[folder setDbId:insertId];
	[folder setPath:folderPath];

    return folder;
}

+ (void)deleteFolder:(ECSubscriptionFolder *)folder{
    FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
	
	if (![db open]) {
		[NSException raise:@"Database error" format:@"Failed to connect to the database!"];
	}
	
	[db beginTransaction];
	
    [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM enclosure WHERE PostId IN (SELECT post.Id FROM post, feed, folder WHERE post.FeedId=feed.Id AND feed.FolderId=folder.Id AND folder.Path LIKE '%@%%')", [folder path]]];
    [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM post WHERE Id IN (SELECT post.Id FROM post, feed, folder WHERE post.FeedId=feed.Id AND feed.FolderId=folder.Id AND folder.Path LIKE '%@%%')", [folder path]]];
    [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM feed WHERE Id IN (SELECT feed.Id FROM feed, folder WHERE feed.FolderId=folder.Id AND folder.Path LIKE '%@%%')", [folder path]]];
    [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM folder WHERE Path LIKE '%@%%'", [folder path]]];
	
	[db commit];
	
	[db close];

}

+ (void)deleteFeed:(ECSubscriptionFeed *)feed{
    FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
	
	if (![db open]) {
		[NSException raise:@"Database error" format:@"Failed to connect to the database!"];
	}
	
	[db beginTransaction];
	
    [db executeUpdate:@"DELETE FROM enclosure WHERE PostId IN (SELECT Id FROM post WHERE FeedId=?)", [NSNumber numberWithInteger:[feed dbId]]];
    [db executeUpdate:@"DELETE FROM post WHERE FeedId=?", [NSNumber numberWithInteger:[feed dbId]]];
    [db executeUpdate:@"DELETE FROM feed WHERE Id=?", [NSNumber numberWithInteger:[feed dbId]]];
	
	[db commit];
	
	[db close];

}

+ (NSInteger)loadPostsFromDatabaseForItem:(ECSubscriptionItem *)selectedItem
                             orQuery:(NSString *)query
                                  to:(NSMutableArray *)posts
                           fromRange:(NSRange)range
{
    FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
	
	if (![db open]) {
		[NSException raise:@"Database error" format:@"Failed to connect to the database!"];
	}
	
	NSMutableString *dbQuery = [NSMutableString string];
	
	if (query != nil) {
		NSArray *queryParts = [query componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		NSMutableString *queryBuild = [NSMutableString string];
		BOOL isFirst = YES;
		
		for (NSString *queryPart in queryParts) {
			if (isFirst == NO) {
				[queryBuild appendString:@" OR "];
			}
			
			[queryBuild appendFormat:@"post.Title LIKE '%%%@%%'", queryPart];
			[queryBuild appendFormat:@" OR post.Author LIKE '%%%@%%'", queryPart];
			[queryBuild appendFormat:@" OR post.PlainTextContent LIKE '%%%@%%'", queryPart];
			[queryBuild appendFormat:@" OR feed.Title LIKE '%%%@%%'", queryPart];
			
			isFirst = NO;
		}
		
		[dbQuery appendFormat:SEARCH_QUERY, queryBuild];
	} else if ([selectedItem isKindOfClass:[ECSubscriptionFeed class]]) {
		[dbQuery appendFormat:FEED_QUERY, [(ECSubscriptionFeed *)selectedItem dbId]];
	} else if ([selectedItem isKindOfClass:[ECSubscriptionFolder class]]) {
		[dbQuery appendFormat:FOLDER_QUERY, [(ECSubscriptionFolder *)selectedItem path]];
	} else if (selectedItem == [[ECSubscriptionsController getSharedInstance]subscriptionRecommendedItems]) {
		[dbQuery appendString:NEW_ITEMS_QUERY];
	} else if (selectedItem == [[ECSubscriptionsController getSharedInstance]subscriptionNewItems]) {
		[dbQuery appendString:NEW_ITEMS_QUERY];
	} else if (selectedItem == [[ECSubscriptionsController getSharedInstance] subscriptionStarredItems]) {
		[dbQuery appendString:STARRED_QUERY];
	} else {
		return 0;
	}
	
	BOOL isOnlyUnreadItems = NO;
	
	if (selectedItem == [[ECSubscriptionsController getSharedInstance]subscriptionNewItems]) {
		isOnlyUnreadItems = YES;
	}
	
	[dbQuery appendString:@" ORDER BY post.Id DESC"];
	
    if (isOnlyUnreadItems) {
        NSInteger numberOfReadPosts = 0;
        
        for (ECPost *post in posts) {
            if ([post isRead]) {
                numberOfReadPosts++;
            }
        }
        
        [dbQuery appendFormat:@" LIMIT %ld, %ld", (range.location - numberOfReadPosts), range.length];
    } else {
        [dbQuery appendFormat:@" LIMIT %ld, %ld", range.location, range.length];
    }
	
	FMResultSet *rs = [db executeQuery:dbQuery];
    NSInteger num = 0;

	while ([rs next]) {
		ECPost *post = [[ECPost alloc] initWithResultSet:rs];
		
		if ([rs boolForColumn:@"HasEnclosures"]) {
			FMResultSet *rs2 = [db executeQuery:@"SELECT * FROM enclosure WHERE PostId=?", [NSNumber numberWithInteger:[post dbId]]];
			
			while ([rs2 next]) {
				[[post enclosures] addObject:[rs2 stringForColumn:@"Url"]];
			}
			
			[rs2 close];
		}
		
//        if ([post isRead] == NO) {
//            NSNumber *key = [NSNumber numberWithInteger:[post dbId]];
//            [[classicView unreadItemsDict] setObject:post forKey:key];
//        }
        
		[posts addObject:post];
		[post release];
        num++;
	}
	
	[rs close];
	[db close];

    return num;
}

+ (BOOL)loadFromDatabaseToKeywords:(NSMutableArray *)keywords toVector:(NSMutableArray *)vector{

    FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
	if (![db open]) {
		[NSException raise:@"Database error" format:@"Failed to connect to the database!"];
	}
    NSString *query = @"SELECT * FROM keyword";
    FMResultSet *rs = [db executeQuery:query];

    NSInteger num = 0;
    
	while ([rs next]) {
        [keywords addObject:[rs stringForColumn:@"keyword"]];
        [vector addObject:[NSNumber numberWithDouble:[rs doubleForColumn:@"weight"]]];
        num++;
	}
	
	[rs close];
	[db close];
    
    if ([keywords count] == 100) {
        return YES;
    }
    return NO;
}

+ (void)loadStarredItemsFromDatabaseToArray:(NSMutableArray *)stars fromRange:(NSRange)range{
    ECSubscriptionItem *selected = [[ECSubscriptionsController getSharedInstance] subscriptionStarredItems];
    [self loadPostsFromDatabaseForItem:selected orQuery:nil  to:stars fromRange:range];
}

+ (void)loadReadNotStarredItemsToArray:(NSMutableArray *)reads fromRange:(NSRange)range{
    FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
	
	if (![db open]) {
		[NSException raise:@"Database error" format:@"Failed to connect to the database!"];
	}
    
    NSString *query = [NSString stringWithFormat:@"SELECT post.*, feed.Title AS FeedTitle, feed.Url AS FeedUrlString FROM post, feed WHERE post.FeedId=feed.Id AND post.IsStarred=0 AND post.IsRead=1 LIMIT %ld, %ld", range.location, range.length];
    FMResultSet *rs = [db executeQuery:query];

    while ([rs next]) {
		ECPost *post = [[ECPost alloc] initWithResultSet:rs];
		      
		[reads addObject:post];
		[post release];
	}
	
	[rs close];
	[db close];
}

+ (void)addToDatabaseForKeywords:(NSArray *)keywords andVector:(NSArray *)vector{
    
    FMDatabase *db = [FMDatabase databaseWithPath:[ECDatabaseController pathForDatabaseFile]];
    
    if (![db open]) {
        [NSException raise:@"Database error" format:@"Failed to connect to the database!"];
    }

    [db beginTransaction];

    for (int i = 0; i < 100; ++i) {
        [db executeUpdate:@"INSERT INTO keyword (keyword, weight) VALUES (?, ?)", keywords[i], vector[i]];
    }
    
    [db commit];
    [db close];

}

@end
