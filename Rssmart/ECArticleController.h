//
//  ECArticleController.h
//  Rssmart
//
//  Created by charmjunewonder on 4/29/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class ECPost;
@class ECTableView;
@class ECWebView;
@class ECSubscriptionItem;

@interface ECArticleController : NSObject

@property (assign, nonatomic) IBOutlet ECWebView *webView;
@property (retain, nonatomic) ECPost *displayedPost;

+ (ECArticleController *)getSharedInstance;

- (void)updateUsingPost:(ECPost *)post headlineFontName:(NSString *)headlineFontName headlineFontSize:(CGFloat)headlineFontSize bodyFontName:(NSString *)bodyFontName bodyFontSize:(CGFloat)bodyFontSize;

@end
