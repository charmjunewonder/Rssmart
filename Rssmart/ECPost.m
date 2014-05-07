//
//  ECPost.m
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECHTMLFilter.h"
#import "ECPost.h"
#import "FMResultSet.h"
#import "GTMNSString+HTML.h"

@implementation ECPost

@synthesize dbId;
@synthesize feedDbId;
@synthesize guid;
@synthesize title;
@synthesize feedTitle;
@synthesize feedUrlString;
@synthesize link;
@synthesize published;
@synthesize received;
@synthesize author;
@synthesize content;
@synthesize plainTextContent;
@synthesize isRead;
@synthesize isStarred;
@synthesize enclosures;
@synthesize wordCount;
@synthesize vector;
@synthesize termsDictionary;

- (id)init {
	self = [super init];
	if (self != nil) {
		[self setEnclosures:[NSMutableArray array]];
	}
	return self;
}

// note, this doesn't load enclosures
- (id)initWithResultSet:(FMResultSet *)rs {
	self = [self init];
	if (self != nil) {
		[self populateUsingResultSet:rs];
	}
	return self;
}

- (void)dealloc {
	[guid release];
	[title release];
	[feedTitle release];
	[feedUrlString release];
	[link release];
	[published release];
	[received release];
	[author release];
	[content release];
	[plainTextContent release];
	[enclosures release];
	
	[super dealloc];
}

- (void)populateUsingResultSet:(FMResultSet *)rs {
	[self setDbId:[rs longForColumn:@"Id"]];
	[self setFeedDbId:[rs longForColumn:@"FeedId"]];
	[self setGuid:[rs stringForColumn:@"Guid"]];
	[self setTitle:[rs stringForColumn:@"Title"]];
	[self setFeedTitle:[rs stringForColumn:@"FeedTitle"]];
	[self setFeedUrlString:[rs stringForColumn:@"FeedUrlString"]];
	[self setLink:[rs stringForColumn:@"Link"]];
	[self setPublished:[rs dateForColumn:@"Published"]];
	[self setReceived:[rs dateForColumn:@"Received"]];
	[self setAuthor:[rs stringForColumn:@"Author"]];
	[self setContent:[rs stringForColumn:@"Content"]];
	[self setPlainTextContent:[rs stringForColumn:@"PlainTextContent"]];
	[self setIsRead:[rs boolForColumn:@"IsRead"]];
	[self setIsStarred:[rs boolForColumn:@"IsStarred"]];
}

- (NSComparisonResult)publishedDateCompare:(ECPost *)otherPost {
	return [published compare:[otherPost published]];
}

- (void)calculateWordCountWithStopWords:(NSArray *)stopWords{
    NSMutableDictionary *allWordCount = [[NSMutableDictionary alloc] init];
    [plainTextContent enumerateSubstringsInRange:NSMakeRange(0, [plainTextContent length])
                                  options:NSStringEnumerationByWords | NSStringEnumerationLocalized
                               usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                                   
                                   NSString *lowerS = substring.lowercaseString;
                                   NSInteger count = [[allWordCount objectForKey:lowerS] integerValue];
                                   count++;
                                   // adds the update count to the master list in constant time (NSDictionary implementation is like hash table)
                                   [allWordCount setObject:[NSNumber numberWithInteger:count] forKey:lowerS];
                               }];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", stopWords];
    NSArray *keys = [allWordCount allKeys];
    NSArray *filteredKeys = [keys filteredArrayUsingPredicate:p];
    NSString *regex = @"[0-9.]+";
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", regex];
    filteredKeys = [filteredKeys filteredArrayUsingPredicate:p2];
    wordCount = [allWordCount dictionaryWithValuesForKeys:filteredKeys];
    [allWordCount release];
}

- (void)calculateWeightWithPosts:(NSArray *)posts{
    termsDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *keys = [wordCount allKeys];
    
    //get total count of the article
    NSInteger totalCount = 0;
    for (NSString *key in keys){
        NSInteger a = [[wordCount objectForKey:key] integerValue];
        totalCount += a;
    }
    
    for (NSString *key in keys){
        NSInteger count =[[wordCount objectForKey:key] integerValue];
        CGFloat termFrequency = count * 1.0 / totalCount;
        NSInteger documentCount = 0;
        for (ECPost *post in posts){
            if ([post.wordCount objectForKey:key]) {
                documentCount++;
            }
        }
        CGFloat inverseDocumentFrequency = log10f([posts count]/documentCount);
        termFrequency *= inverseDocumentFrequency;
        [termsDictionary setObject:[NSNumber numberWithFloat:termFrequency] forKey:key];
    }
}

@end
