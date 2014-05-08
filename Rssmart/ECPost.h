//
//  ECPost.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class FMResultSet;

@interface ECPost : NSObject

@property (assign, nonatomic) NSInteger dbId;
@property (assign, nonatomic) NSInteger feedDbId;
@property (copy, nonatomic) NSString *guid;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *feedTitle;
@property (copy, nonatomic) NSString *feedUrlString;
@property (copy, nonatomic) NSString *link;
@property (retain, nonatomic) NSDate *published;
@property (retain, nonatomic) NSDate *received;
@property (copy, nonatomic) NSString *author;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *plainTextContent;
@property (assign, nonatomic) BOOL isRead;
@property (assign, nonatomic) BOOL isStarred;
@property (retain, nonatomic) NSMutableArray *enclosures;
@property (assign, nonatomic) NSDictionary *wordCount;
@property (assign, nonatomic) NSMutableArray *vector;
@property (assign, nonatomic) NSMutableDictionary *termsDictionary;

- (id)initWithResultSet:(FMResultSet *)rs; // note, this doesn't load enclosures
- (void)populateUsingResultSet:(FMResultSet *)rs; // note, this doesn't load enclosures
- (void)calculateWordCountWithStopWords:(NSArray *)stopWords;
- (void)calculateWeightWithPosts:(NSArray *)posts;
- (void)calculateVectorWithKeywords:(NSArray *)keywords withPosts:(NSArray *)posts;
@end
