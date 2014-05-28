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
- (void)getRecommendedPostsFrom:(NSMutableArray *)newPosts to:(NSMutableArray *)posts;
- (IBAction)calculateUserModel:(id)sender;
@end
