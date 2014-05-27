//
//  ECPostsController.m
//  Rssmart
//
//  Created by charmjunewonder on 4/29/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECPostsController.h"
#import "ECDatabaseController.h"
#import "ECTableViewTextFieldCell.h"
#import "ECTableView.h"
#import "ECPost.h"
#import "ECSubscriptionsController.h"
#import "ECSubscriptionFeed.h"
#import "ECArticleController.h"
#import "ECRequestController.h"
#import "ECWebView.h"
#import "ECArticleController.h"
#import "NSScrollView+ECAdditions.h"
#import "ECRecommender.h"

#define CLASSIC_VIEW_POSTS_PER_QUERY 10
#define UNREAD_COUNT_QUERY @"UPDATE feed SET UnreadCount = (SELECT COUNT(Id) FROM post WHERE FeedId=? AND IsRead=0 AND IsHidden=0) WHERE Id=?"

@implementation ECPostsController

@synthesize tableView;
@synthesize posts;
@synthesize selectedItem;
@synthesize searchQuery;
@synthesize articleController;

static ECPostsController *_sharedInstance = nil;

+ (ECPostsController *)getSharedInstance
{
    if(_sharedInstance == nil)
        @synchronized(self) {
            if(_sharedInstance == nil)
                _sharedInstance = [[ECPostsController alloc] init];
        }
    return _sharedInstance;
}

/*
 * Note that at this time, connected IBOutlet is nil.
 */
-(id)init
{
    NSAssert(_sharedInstance == nil, @"Duplication initialization of singleton");
    self = [super init];
    _sharedInstance = self;
    if (self != nil) {
		[self setPosts:[NSMutableArray array]];
    }
    return self;
}

- (void)dealloc {
    [articleController release];
    [posts release];
    [selectedItem release];
    [searchQuery release];
    [_sharedInstance release];
    [super dealloc];
}

- (void)setup{
    [self loadPostsIntoPostsView];
    articleController = [ECArticleController getSharedInstance];
}

#pragma mark Load Post to TableView
/*
 * Load posts into the tableview
 */
- (void)loadPostsIntoPostsView {
	NSRange range = NSMakeRange(0, 0);
	
    //when [posts count] == 0, it reloads the tableview
    //when [posts count] != 0, it loads more content to the tableview
    range = NSMakeRange([posts count], CLASSIC_VIEW_POSTS_PER_QUERY);
	
	[self loadPostsIntoPostsViewFromRange:range atBottom:NO];
}

- (void)loadPostsIntoPostsViewFromRange:(NSRange)range atBottom:(BOOL)bottom {
	if (range.length == 0) {
		return;
	}
	
//	ECSubscriptionItem *sourceListItem = [classicView sourceListItem];
	
	if (selectedItem == nil && searchQuery == nil) {
		return;
	}
	
    if (selectedItem == [[ECSubscriptionsController getSharedInstance]subscriptionRecommendedItems]) {
        NSMutableArray *newPosts = [NSMutableArray array];
        [ECDatabaseController loadPostsFromDatabaseForItem:selectedItem orQuery:searchQuery to:newPosts fromRange:range];

        ECRecommender *recommender = [[ECRecommender alloc] init];
        posts = [recommender getRecommendedPosts:newPosts];
        [recommender release];
    } else {
        [ECDatabaseController loadPostsFromDatabaseForItem:selectedItem orQuery:searchQuery to:posts fromRange:range];
    }

    
//    NSInteger numOfNewPost = [ECDatabaseController loadPostsFromDatabaseForItem:selectedItem orQuery:searchQuery to:posts fromRange:range];

	NSUInteger numPostsRequested = (NSInteger)range.length;
	
//    if (numOfNewPost < numPostsRequested) {
//        [classicView setPostsMissingFromBottom:NO];
//    }
//    
//    if ([classicView postsMissingFromBottom]) {
//        [self performSelector:@selector(checkIfClassicViewNeedsToLoadMoreContent:) withObject:classicView afterDelay:1];
//    }
    
    [tableView reloadData];
	
    //	[self updateViewVisibilityForTab:classicView];
}

- (void)openSubscriptionItem:(ECSubscriptionItem *)item orQuery:(NSString *)queryString
{
    selectedItem = item;
    queryString = queryString;
    
    if ([posts count] > 0) {
        [self clearContentOfTableView];
    }
    
    //	[self updateViewVisibilityForTab:tabViewItem];
    
    [self loadPostsIntoPostsView];
//    [self performSelector:@selector(updateFirstResponder) withObject:nil afterDelay:0.1]; // don't ask
//    [self updateViewSwitchEnabled];
    [tableView deselectAll:self];
}

- (void)reloadDataInTableView{
    [self openSubscriptionItem:selectedItem orQuery:nil];
}

//TODO rename
- (void)clearContentOfTableView {
    
    [self setPosts:[NSMutableArray array]];
    //[classicView setUnreadItemsDict:[NSMutableDictionary dictionary]];
    //[classicView setPostsMissingFromBottom:YES];
    [articleController setDisplayedPost:nil];
    //[classicView setShouldIgnoreSelectionChange:NO];
    
    NSClipView *clipView = (NSClipView *)[tableView superview];
    NSScrollView *scrollView = (NSScrollView *)[clipView superview];
    [scrollView ecScrollToTop];
    
    [[[articleController webView] mainFrame] loadHTMLString:@"" baseURL:nil];
}
#pragma mark -

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(ECTableView *)aTableView {
	return [posts count];
}

- (id)tableView:(ECTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	return [[posts objectAtIndex:rowIndex] title];
}
#pragma mark -

#pragma mark NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	ECPost *previousSelection = [articleController displayedPost];
	ECPost *currentSelection = nil;
	NSInteger selectedRow = [tableView selectedRow];
	
    if (selectedRow >= 0) {
        currentSelection = [posts objectAtIndex:selectedRow];
        
        if (currentSelection != previousSelection) {
            
            //set headline font
            NSString *headlineFontName = @"HelveticaNeue-Medium";
            CGFloat headlineFontSize = 11.0f;
            //set body font
            NSString *bodyFontName = @"HelveticaNeue";
            CGFloat bodyFontSize = 10.0f;
            
            [articleController updateUsingPost:currentSelection headlineFontName:headlineFontName headlineFontSize:headlineFontSize bodyFontName:bodyFontName bodyFontSize:bodyFontSize];
        }
        
        if ([currentSelection isRead] == NO) {
            [self markReadWithPost:currentSelection];
        }
        
    } else {
        [articleController setDisplayedPost:nil];
        [[[articleController webView] mainFrame] loadHTMLString:@"" baseURL:nil];
    }
		
	[tableView setNeedsDisplay:YES];
	
//	[delegate classicViewSelectionDidChange];
}

- (void)tableView:(ECTableView *)aTableView willDisplayCell:(ECTableViewTextFieldCell *)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    [aCell setDelegate:self];
    [aCell setRowIndex:rowIndex];
    [aCell setTableViewReference:aTableView];
}

- (BOOL)tableView:(ECTableView *)aTableView shouldShowCellExpansionForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return NO;
}
#pragma mark -

#pragma mark ECTableViewTextFieldCellDelegate

- (ECPost *)tableViewTextFieldCell:(ECTableViewTextFieldCell *)tableViewTextFieldCell postForRow:(NSInteger)rowIndex {
	ECPost *post = [posts objectAtIndex:rowIndex];
	
	// update feed title
	if (post != nil && [post feedDbId] > 0) {
		ECSubscriptionFeed *feed = [[ECSubscriptionsController getSharedInstance] feedForDbId:[post feedDbId]];
		
		if (feed != nil) {
			[post setFeedTitle:[feed title]];
		}
	}
	
	return post;
}
#pragma mark -

- (void)markReadWithPost:(ECPost *)post {
		
    if ([post isRead]) {
        return;
    }
    
    NSArray *queries = [NSArray arrayWithObjects:
                        [NSArray arrayWithObjects:@"UPDATE post SET IsRead=1 WHERE Id=?", [NSNumber numberWithInteger:[post dbId]], nil],
                        [NSArray arrayWithObjects:UNREAD_COUNT_QUERY, [NSNumber numberWithInteger:[post feedDbId]], [NSNumber numberWithInteger:[post feedDbId]], nil],
                        nil];
    
	[[ECRequestController getSharedInstance] runDatabaseUpdatesOnBackgroundThread:queries];
	ECSubscriptionsController * subsCon = [ECSubscriptionsController getSharedInstance];
	ECSubscriptionFeed *feed = [subsCon feedForDbId:[post feedDbId]];
	
	[subsCon changeBadgeValueBy:-1 forItem:feed];
	[subsCon changeBadgeValuesBy:-1 forAncestorsOfItem:feed];
	
	[subsCon changeNewItemsBadgeValueBy:-1];
	[subsCon refreshSubscriptionsView];
	
    [post setIsRead:YES];
}

- (IBAction)markReadWithCurrentPost:(id)sender {
    [self markReadWithPost:[articleController displayedPost]];
}
- (void)markUnreadWithPost:(ECPost *)post {
    
    if (![post isRead]) {
        return;
    }
    
    NSArray *queries = [NSArray arrayWithObjects:
                        [NSArray arrayWithObjects:@"UPDATE post SET IsRead=0 WHERE Id=?", [NSNumber numberWithInteger:[post dbId]], nil],
                        [NSArray arrayWithObjects:UNREAD_COUNT_QUERY, [NSNumber numberWithInteger:[post feedDbId]], [NSNumber numberWithInteger:[post feedDbId]], nil],
                        nil];
    
	[[ECRequestController getSharedInstance] runDatabaseUpdatesOnBackgroundThread:queries];
	ECSubscriptionsController * subsCon = [ECSubscriptionsController getSharedInstance];
	ECSubscriptionFeed *feed = [subsCon feedForDbId:[post feedDbId]];
	
	[subsCon changeBadgeValueBy:+1 forItem:feed];
	[subsCon changeBadgeValuesBy:+1 forAncestorsOfItem:feed];
	
	[subsCon changeNewItemsBadgeValueBy:+1];
	[subsCon refreshSubscriptionsView];
    
    [post setIsRead:NO];
    
    [tableView setNeedsDisplay:YES];
}

- (IBAction)markUnreadWithCurrentPost:(id)sender {
    [self markUnreadWithPost:[articleController displayedPost]];
}

- (IBAction)addStarToCurrentPost:(id)sender {
    ECPost *post = [articleController displayedPost];

    if ([post isStarred]) {
        return;
    }
    
    [[ECRequestController getSharedInstance] runDatabaseUpdateOnBackgroundThread:@"UPDATE post SET IsStarred=1 WHERE Id=?", [NSNumber numberWithInteger:[post dbId]], nil];
	
	[post setIsStarred:YES];
    
    [tableView setNeedsDisplay:YES];
}

- (IBAction)removeStarToCurrentPost:(id)sender {
    ECPost *post = [articleController displayedPost];
    
    if (![post isStarred]) {
        return;
    }
    
    [[ECRequestController getSharedInstance] runDatabaseUpdateOnBackgroundThread:@"UPDATE post SET IsStarred=0 WHERE Id=?", [NSNumber numberWithInteger:[post dbId]], nil];
	
	[post setIsStarred:NO];
    
    [tableView setNeedsDisplay:YES];
}


@end
