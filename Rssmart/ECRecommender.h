//
//  ECRecommender.h
//  Rssmart
//
//  Created by charmjunewonder on 5/7/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@interface ECRecommender : NSObject

@property (retain, nonatomic) NSMutableArray *posts;

- (id)initWithNewPosts:(NSMutableArray *)posts;
- (BOOL)isSeparator: (char)c;
- (NSMutableArray *)getRecommendedPosts:(NSMutableArray *)newPosts;
- (IBAction)calculateUserModel:(id)sender;
@end
