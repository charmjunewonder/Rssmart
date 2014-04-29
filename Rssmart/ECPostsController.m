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

#define CLASSIC_VIEW_POSTS_PER_QUERY 100

@implementation ECPostsController

@synthesize tableView;
@synthesize posts;
@synthesize selectedItem;
@synthesize searchQuery;

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

- (void)setup{
    [self loadPostsIntoPostsView];
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
	
	NSInteger numOfNewPost = [ECDatabaseController loadPostsFromDatabaseForItem:selectedItem orQuery:searchQuery to:posts fromRange:range];
	
	NSUInteger numPostsRequested = (NSInteger)range.length;
	
//    if (numOfNewPost < numPostsRequested) {
//        [classicView setPostsMissingFromBottom:NO];
//    }
//    
//    if ([classicView postsMissingFromBottom]) {
//        [self performSelector:@selector(checkIfClassicViewNeedsToLoadMoreContent:) withObject:classicView afterDelay:1];
//    }
    
    if (numOfNewPost > 0) {
        [tableView reloadData];
    }
	
    //	[self updateViewVisibilityForTab:classicView];
}

//- (void)openItemInCurrentTab:(ECSubscriptionItem *)item orQuery:(NSString *)queryString {
//    [classicView setSourceListItem:item];
//    [classicView setSearchQuery:queryString];
//    
//    if ([[classicView posts] count] > 0) {
//        [self clearContentOfTableView];
//    }
//    
//    //	[self updateViewVisibilityForTab:tabViewItem];
//    
//    [self loadPostsIntoClassicView:classicView];
//    [self performSelector:@selector(updateFirstResponder) withObject:nil afterDelay:0.1]; // don't ask
//    [self updateViewSwitchEnabled];
//    
//}

//TODO rename
//- (void)clearContentOfTableView {
//    
//    [classicView setPosts:[NSMutableArray array]];
//    [classicView setUnreadItemsDict:[NSMutableDictionary dictionary]];
//    [classicView setPostsMissingFromBottom:YES];
//    [classicView setDisplayedPost:nil];
//    [classicView setShouldIgnoreSelectionChange:NO];
//    
//    NSClipView *clipView = (NSClipView *)[[classicView tableView] superview];
//    NSScrollView *scrollView = (NSScrollView *)[clipView superview];
//    [scrollView clScrollToTop];
//    
//    [[[classicView webView] mainFrame] loadHTMLString:@"" baseURL:nil];
//}
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
//	ECTableView *tableView = [aNotification object];
//	CLClassicView *classicView = [tableView classicViewReference];
//	CLPost *previousSelection = [classicView displayedPost];
//	CLPost *currentSelection = nil;
//	NSInteger selectedRow = [tableView selectedRow];
//	
//	if ([classicView shouldIgnoreSelectionChange] == NO || selectedRow >= 0) {
//		if (selectedRow >= 0) {
//			currentSelection = [[classicView posts] objectAtIndex:selectedRow];
//			
//			if (currentSelection != previousSelection) {
//				NSString *headlineFontName = [delegate preferenceHeadlineFontName];
//				CGFloat headlineFontSize = [delegate preferenceHeadlineFontSize];
//				NSString *bodyFontName = [delegate preferenceBodyFontName];
//				CGFloat bodyFontSize = [delegate preferenceBodyFontSize];
//				
//				[classicView updateUsingPost:currentSelection headlineFontName:headlineFontName headlineFontSize:headlineFontSize bodyFontName:bodyFontName bodyFontSize:bodyFontSize];
//			}
//			
//			if ([currentSelection isRead] == NO) {
//				[delegate markPostWithDbIdAsRead:[currentSelection dbId]];
//			}
//			
//		} else {
//			[classicView setDisplayedPost:nil];
//			[[[classicView webView] mainFrame] loadHTMLString:@"" baseURL:nil];
//		}
//	}
//	
//	[classicView setShouldIgnoreSelectionChange:NO];
//	
//	[tableView setNeedsDisplay:YES];
//	
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

@end
