//
//  ECRecommender.m
//  Rssmart
//
//  Created by charmjunewonder on 5/7/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECRecommender.h"
#import "ECPost.h"
#import "ECDatabaseController.h"
#import "NSDictionary+ECMerge.h"

@implementation ECRecommender

- (id)initWithNewPosts:(NSMutableArray *)posts{
    self = [super init];
	if (self)  {
        [posts retain];
        self.posts = posts;
        [posts release];
	}
	
	return self;
}

- (void)dealloc{
    [self.posts release];
    [super dealloc];
}

- (NSMutableArray *)getRecommendedPosts:(NSMutableArray *)newPosts{
    NSMutableArray *recommendedPosts = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    NSMutableArray *vectorOfKeyword = [[NSMutableArray alloc] init];
    
    BOOL isExisting = [ECDatabaseController loadFromDatabaseToKeywords:keywords toVector:vectorOfKeyword];
    
    if (!isExisting) {
        [self generateKeywords:keywords andVector:vectorOfKeyword];
    }
    
    //read stopwords from file
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"stopwords.txt" ofType:nil];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    NSArray *stopWords = [fileContents componentsSeparatedByString:@"\n"];
    
    for (ECPost *post in newPosts){
        [post calculateWordCountWithStopWords:stopWords];
    }
    for (ECPost *post in newPosts){
        [post calculateVectorWithKeywords:keywords withPosts:newPosts];
        CGFloat similarity = [self calculateSimilarityWith:[post vector] and:vectorOfKeyword];
        if (similarity > 0.3) {
            [recommendedPosts addObject:post];
        }
    }
    [keywords release];
    [newPosts release];
    return recommendedPosts;
}

- (CGFloat)calculateSimilarityWith:(NSArray *)vectorA and:(NSArray *)vectorB{
    CGFloat dotProduct = 0.0;
    CGFloat magnitudeA = 0.0;
    CGFloat magnitudeB = 0.0;
    for (int i = 1; i < 100; ++i) {
        CGFloat valueA = [vectorA[i] floatValue];
        CGFloat valueB = [vectorB[i] floatValue];
        dotProduct +=  valueA * valueB;
        magnitudeA += valueA * valueA;
        magnitudeB += valueB * valueB;
    }
    CGFloat result = dotProduct / ( sqrtf(magnitudeA) * sqrtf(magnitudeB) );
    return result;
}
- (IBAction)calculateUserModel:(id)sender{
    [self generateKeywords:nil andVector:nil];
}

- (void)generateKeywords:(NSMutableArray *)keywords andVector:(NSMutableArray *)vector{
    
    NSMutableArray *stars = [[NSMutableArray alloc] init];
    [ECDatabaseController loadStarredItemsFromDatabaseToArray:stars fromRange:NSMakeRange(0, 100)];
    
    NSMutableArray *reads = [[NSMutableArray alloc] init];
    [ECDatabaseController loadReadNotStarredItemsToArray:reads fromRange:NSMakeRange(0, 500)];
    
    //TODO: check % of counts
    
    //read stopwords from file
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"stopwords.txt" ofType:nil];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    NSArray *stopWords = [fileContents componentsSeparatedByString:@"\n"];

    NSArray *allPosts= [stars arrayByAddingObjectsFromArray:reads];
    [reads release];
    for (ECPost *post in allPosts){
        [post calculateWordCountWithStopWords:stopWords];
    }
    
    NSDictionary *totalDictionary = [NSDictionary dictionary];
    
    for (ECPost *star in stars){
        [star calculateWeightWithPosts:allPosts];
        totalDictionary = [totalDictionary dictionaryByMergingWith:[star termsDictionary]];
    }
    NSInteger numOfStarItem = [stars count];
    [stars release];

    NSArray *allSortedArray;
    
    allSortedArray = [totalDictionary keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 floatValue] > [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        if ([obj1 floatValue] < [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    [keywords addObjectsFromArray:[allSortedArray subarrayWithRange: NSMakeRange(0, 100)]];
    NSDictionary *keywordDictionary = [totalDictionary dictionaryWithValuesForKeys:keywords];

    for (NSString *key in keywords){
        CGFloat weight =[[keywordDictionary objectForKey:key] floatValue];
        [vector addObject:[NSNumber numberWithFloat:weight/numOfStarItem]];
    }
    
    //put them into database
    [ECDatabaseController addToDatabaseForKeywords:keywords andVector:vector];
}

- (void)countWordOccurrenceInPost:(ECPost *)post{
    
}

// returns true the character is contained in the array
// Constant time
- (BOOL)isSeparator: (char)c{
//    for (int i = 0; i < (sizeof(separators)); i++)  {
//		if (separators[i] == c) return YES;
//	}
	return NO;
}
@end
