//
//  ECPostsController.m
//  Rssmart
//
//  Created by charmjunewonder on 4/29/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECPostsController.h"

@implementation ECPostsController

@synthesize tableView;
@synthesize posts;

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
        
    }
    return self;
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(CLTableView *)aTableView {
	CLClassicView *classicView = [aTableView classicViewReference];
	return [[classicView posts] count];
}

- (id)tableView:(CLTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	CLClassicView *classicView = [aTableView classicViewReference];
	return [[[classicView posts] objectAtIndex:rowIndex] title];
}
#pragma mark -

#pragma mark NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	CLTableView *tableView = [aNotification object];
	CLClassicView *classicView = [tableView classicViewReference];
	CLPost *previousSelection = [classicView displayedPost];
	CLPost *currentSelection = nil;
	NSInteger selectedRow = [tableView selectedRow];
	
	if ([classicView shouldIgnoreSelectionChange] == NO || selectedRow >= 0) {
		if (selectedRow >= 0) {
			currentSelection = [[classicView posts] objectAtIndex:selectedRow];
			
			if (currentSelection != previousSelection) {
				NSString *headlineFontName = [delegate preferenceHeadlineFontName];
				CGFloat headlineFontSize = [delegate preferenceHeadlineFontSize];
				NSString *bodyFontName = [delegate preferenceBodyFontName];
				CGFloat bodyFontSize = [delegate preferenceBodyFontSize];
				
				[classicView updateUsingPost:currentSelection headlineFontName:headlineFontName headlineFontSize:headlineFontSize bodyFontName:bodyFontName bodyFontSize:bodyFontSize];
			}
			
			if ([currentSelection isRead] == NO) {
				[delegate markPostWithDbIdAsRead:[currentSelection dbId]];
			}
			
		} else {
			[classicView setDisplayedPost:nil];
			[[[classicView webView] mainFrame] loadHTMLString:@"" baseURL:nil];
		}
	}
	
	[classicView setShouldIgnoreSelectionChange:NO];
	
	[tableView setNeedsDisplay:YES];
	
	[delegate classicViewSelectionDidChange];
}

- (void)tableView:(CLTableView *)aTableView willDisplayCell:(CLTableViewTextFieldCell *)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	[aCell setDelegate:self];
	[aCell setRowIndex:rowIndex];
	[aCell setTableViewReference:aTableView];
}

- (BOOL)tableView:(CLTableView *)aTableView shouldShowCellExpansionForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return NO;
}
#pragma mark -

#pragma mark CLTableViewTextFieldCellDelegate

- (CLPost *)tableViewTextFieldCell:(CLTableViewTextFieldCell *)tableViewTextFieldCell postForRow:(NSInteger)rowIndex {
	CLTableView *tableView = [tableViewTextFieldCell tableViewReference];
	CLClassicView *classicView = [tableView classicViewReference];
	CLPost *post = [[classicView posts] objectAtIndex:rowIndex];
	
	// update feed title
	if (post != nil && [post feedDbId] > 0) {
		CLSourceListFeed *feed = [delegate feedForDbId:[post feedDbId]];
		
		if (feed != nil) {
			[post setFeedTitle:[feed title]];
		}
	}
	
	return post;
}
#pragma mark -


@end
