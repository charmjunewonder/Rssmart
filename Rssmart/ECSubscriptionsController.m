//
//  ECSubscriptionsController.m
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECSubscriptionsController.h"
#import "ECSubscriptionFeed.h"
#import "ECSubscriptionFolder.h"
#import "ECSubscriptionsTextFieldCell.h"
#import "ECSubscriptionsView.h"
#import "ECConstants.h"
#import "ECAddFeedController.h"
#import "ECVersionNumber.h"
#import "FMDatabase.h"
#import "NSString+ECAddition.h"
#import "ECErrorUtility.h"
#import "ECDatabaseController.h"
#import "ECIconRefreshOperation.h"
#import "ECPost.h"
#import "ECRequestController.h"
#import "ECAddFolderController.h"

#define SOURCE_LIST_DRAG_TYPE @"SourceListDragType"
#define ICON_REFRESH_INTERVAL TIME_INTERVAL_MONTH

@interface ECSubscriptionsController (Private)
- (void)initializeSourceList;
@end

@implementation ECSubscriptionsController

@synthesize subscriptionList;
@synthesize subsView;
@synthesize subscriptionRoot;
@synthesize subscriptionNewItems;
@synthesize subscriptionStarredItems;
@synthesize subscriptionSubscriptions;
@synthesize subscriptionSelectedItem;
@synthesize subscriptionDragItem;
@synthesize addFeedController;
@synthesize addFolderController;
@synthesize subsViewContextMenu;

static ECSubscriptionsController *_sharedInstance = nil;

+ (ECSubscriptionsController *)getSharedInstance
{
    if(_sharedInstance == nil)
        @synchronized(self) {
            if(_sharedInstance == nil)
                _sharedInstance = [[ECSubscriptionsController alloc] init];
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
//        self.postsController = [PostsController getSharedInstance];
        
        // create an object as a placeholder until we create the real object; crashes otherwise
        [self setSubscriptionRoot:[[[ECSubscriptionFolder alloc] init] autorelease]];
//        [subsView setDelegate:self];
//        [subsView setDataSource:self];
        
    }
    return self;
}

-(void)setup{
    [self initializeSourceList];
    [ECDatabaseController loadFromDatabaseTo:subscriptionSubscriptions];
    [[ECRequestController getSharedInstance] startToOperate];
	[subsView reloadData];
}

/*
 * initialize the SourceList(NSOutlineView) when window has loaded
 */
- (void)initializeSourceList {
	
	ECSubscriptionItem *root = [[ECSubscriptionItem alloc] init];
    
	/************************ Library ************************/
	ECSubscriptionItem *library = [[ECSubscriptionItem alloc] init];
    [library setIcon:nil];
	[library setTitle:@"LIBRARY"];
	[library setIsGroupItem:YES];
	
	ECSubscriptionItem *newItems = [[ECSubscriptionItem alloc] init];
	[newItems setTitle:@"New Items"];
	NSString *newItemsIconName = [[NSBundle mainBundle] pathForResource:@"inbox-table" ofType:@"png"];
	NSImage *newItemsIcon = [[[NSImage alloc] initWithContentsOfFile:newItemsIconName] autorelease];
	[newItemsIcon setFlipped:YES];
	[newItems setIcon:newItemsIcon];
	
	[[library children] addObject:newItems];
	[self setSubscriptionNewItems:newItems];
	[newItems release];
	
	ECSubscriptionItem *starredItems = [[ECSubscriptionItem alloc] init];
	[starredItems setTitle:@"Starred Items"];
	NSImage *starredItemsIcon = [NSImage imageNamed:@"star"];
	[starredItemsIcon setFlipped:YES];
	[starredItems setIcon:starredItemsIcon];
	[[library children] addObject:starredItems];
	[self setSubscriptionStarredItems:starredItems];
	[starredItems release];
	
	[[root children] addObject:library];
	[library release];
    
    /************************ Subscriptions ************************/
	ECSubscriptionItem *subscriptions = [[ECSubscriptionItem alloc] init];
    [subscriptions setIcon:nil];
	[subscriptions setTitle:@"SUBSCRIPTIONS"];
	[subscriptions setIsGroupItem:YES];
    
//	[subscriptions setChildren:subscriptionList];
	
	[[root children] addObject:subscriptions];
	[self setSubscriptionSubscriptions:subscriptions];
	[subscriptions release];
	
    [[addFeedController folderArray] addObject:subscriptions];
    
	[self setSubscriptionRoot:root];
	[root release];
		
    [subsView reloadData];

	// expand group items
	ECSubscriptionItem *child;
	
	for (NSUInteger i=0; i<[[subscriptionRoot children] count]; i++) {
		child = [[subscriptionRoot children] objectAtIndex:i];
		if ([subsView isExpandable:child]) {
			[subsView expandItem:child];
		}
	}
}

# pragma mark SubscriptionsView data source methods

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(ECSubscriptionFolder *)item {
    return (item == nil) ? [[subscriptionRoot children] count] : [[item children] count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(ECSubscriptionFolder *)item {
    return (item == nil) ? YES : ([item isGroupItem] || [item isKindOfClass:[ECSubscriptionFolder class]] || [[item children] count] > 0);
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)childIndex ofItem:(ECSubscriptionFolder *)item {
    return (item == nil) ? [[subscriptionRoot children] objectAtIndex:childIndex] : [[item children] objectAtIndex:childIndex];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(ECSubscriptionFolder *)item {
	if (item == nil) {
		return @"";
	}
	
	return [item extractTitleForDisplay];
}

//TODO:maybe delete?
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(NSString *)value forTableColumn:(NSTableColumn *)tableColumn byItem:(ECSubscriptionItem *)item {
	
	[item setTitle:value];
	
//	[self performSelector:@selector(updateFirstResponder) withObject:nil afterDelay:0.1];
//	
//	[delegate sourceListDidRenameItem:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
	
	// instead of actually putting the item on the pasteboard, just put it in a ivar
	// seems like a hack, but this is what the apple sample project that I downloaded does
	subscriptionDragItem = (ECSubscriptionItem *)[items objectAtIndex:0];
	
	if ([subscriptionDragItem isDraggable] == NO) {
		return NO;
	}
	
	[pboard declareTypes:[NSArray arrayWithObjects:SOURCE_LIST_DRAG_TYPE, nil] owner:self];
    [pboard setData:[NSData data] forType:SOURCE_LIST_DRAG_TYPE];
	
	return YES;
}

//TODO:drap
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(ECSubscriptionItem *)dropTarget proposedChildIndex:(NSInteger)childIndex {
	NSDragOperation result = NSDragOperationNone;
	
//	if (dropTarget == nil || dropTarget == subscriptionSubscriptions || [dropTarget isKindOfClass:[ECSubscriptionFolder class]] || [dropTarget isKindOfClass:[ECSubscriptionFeed class]]) {
//		result = NSDragOperationGeneric;
//	}
//	
//	// don't allow dragging from a ancestor to a descendent
//	if ([SyndicationAppDelegate isSourceListItem:dropTarget descendentOf:subscriptionDragItem]) {
//		result = NSDragOperationNone;
//	} else {
//		
//		// various types of drags that we want to redirect
//		// the comments below explain which type of drag is being handled
//		if ([dropTarget isKindOfClass:[ECSubscriptionFolder class]] && childIndex != NSOutlineViewDropOnItemIndex) {
//			
//			// dropping an item between the children of a folder
//			[subsView setDropItem:dropTarget dropChildIndex:NSOutlineViewDropOnItemIndex];
//		} else if ([dropTarget isKindOfClass:[ECSubscriptionFeed class]] && [(ECSubscriptionFeed *)dropTarget enclosingFolderReference] != nil) {
//			
//			// dropping an item on top of the child of a folder
//			[subsView setDropItem:[(ECSubscriptionFeed *)dropTarget enclosingFolderReference] dropChildIndex:NSOutlineViewDropOnItemIndex];
//		} else if ([dropTarget isKindOfClass:[ECSubscriptionFeed class]] && childIndex == NSOutlineViewDropOnItemIndex) {
//			
//			// dropping an item on to a regular item (not in a folder)
//			[subsView setDropItem:subscriptionSubscriptions dropChildIndex:NSOutlineViewDropOnItemIndex];
//		} else if (dropTarget == subscriptionSubscriptions && childIndex != NSOutlineViewDropOnItemIndex) {
//			
//			// dropping an item between regular items (not in a folder)
//			[subsView setDropItem:subscriptionSubscriptions dropChildIndex:NSOutlineViewDropOnItemIndex];
//		} else if (dropTarget == nil) {
//			
//			// dropping into empty space
//			[subsView setDropItem:subscriptionSubscriptions dropChildIndex:NSOutlineViewDropOnItemIndex];
//		}
//	}
	
	return result;
}

/*
 *
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(ECSubscriptionItem *)dropTarget childIndex:(NSInteger)childIndex {
	
	if ([info draggingSource] == subsView) {
		
		ECSubscriptionFolder *folder = nil;
		
		if (dropTarget != subscriptionSubscriptions) {
			folder = (ECSubscriptionFolder *)dropTarget;
		}
		
//		[delegate moveItem:subscriptionDragItem toFolder:folder];
		
		return YES;
	}
	
	return NO;
}
#pragma mark -

# pragma mark CLSourceList delegate methods

/*
 *
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(ECSubscriptionItem *)item {
	return [item isGroupItem];
}

/*
 *
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(ECSubscriptionItem *)item {
	return ![item isGroupItem];
}

/*
 *
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(ECSubscriptionItem *)item {
	return ![item isGroupItem];
}

/*
 * is editable
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(ECSubscriptionItem *)item {
	return NO;
}

/*
 *
 */
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(ECSubscriptionsTextFieldCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(ECSubscriptionItem *)item {
	[cell setBadgeWidth:[ECSubscriptionsView sizeOfBadgeForItem:item].width];
	
	if ([item isGroupItem] == NO) {
		[cell setIconWidth:SOURCE_LIST_ICON_WIDTH];
	} else {
		[cell setIconWidth:0];
	}
}

/*
 * then postsview will change outlineViewSelectionDidChange
 */
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	ECSubscriptionItem *selectedItem = [subsView itemAtRow:[subsView selectedRow]];
	//TODO:outlineViewSelectionDidChange
//	if (selectedItem != nil) {
//		if ([classicView sourceListItem] != selectedItem) {
//            [self openItemInCurrentTab:selectedItem orQuery:nil];
//		}
//	}
	
	[self setSubscriptionSelectedItem:selectedItem];
}
#pragma mark -

- (IBAction)addFolder:(id)sender {
    [addFolderController clearTextField];
	[addFolderController showDialog:self];
}

- (IBAction)addFolderForSure:(id)sender{
    
    NSString *name = [addFolderController getFolderName];
    
	if (name != nil && [name length] > 0) {
        [self addFolderWithTitle:name];
	}
    
	[addFolderController hideDialog:nil];
}
//TODO:(ECSubscriptionFolder *) may delete
- (ECSubscriptionFolder *)addFolderWithTitle:(NSString *)folderTitle{
	
	if (folderTitle == nil) {
		folderTitle = @"(Untitled)";
	}
	
    ECSubscriptionFolder *newFolder = [ECDatabaseController addFolderWithTitle:folderTitle];
    
    [[subscriptionSubscriptions children] addObject:newFolder];

//	[self sortSourceList];
	[self refreshSubscriptionsView];
//	[self restoreSourceListSelections];
			
	return newFolder;
}

- (IBAction)editFolder:(id)sender{
    [[addFolderController submitButton] setAction:@selector(editFolderForSure:)];
    
    ECSubscriptionItem *currentItem = [self getCurrentSubscriptionItem];
    
    [[addFolderController folderDialogTextField] setStringValue:[currentItem title]];
    [addFolderController showDialog:self];
}

- (IBAction)editFolderForSure:(id)sender{
    ECSubscriptionItem *currentItem = [self getCurrentSubscriptionItem];
    [currentItem setTitle:[[addFolderController folderDialogTextField] stringValue]];
    [self editForFolder:(ECSubscriptionFolder *)currentItem];
}

- (void)editForFolder:(ECSubscriptionFolder *)folder {
	
//	[self sortSourceList];
	[self refreshSubscriptionsView];
//	[self restoreSourceListSelections];
    [[ECRequestController getSharedInstance] runDatabaseUpdateOnBackgroundThread:@"UPDATE folder SET Title=? WHERE Id=?", [folder title], [NSNumber numberWithInteger:[folder dbId]], nil];
    [addFolderController hideDialog:nil];
}


- (ECSubscriptionItem *)getCurrentSubscriptionItem{
    ECSubscriptionItem *currentItem = [subsView itemAtRow:[subsView clickedRow]];
    
    if (currentItem == nil) {
        currentItem = [subsView itemAtRow:[subsView selectedRow]];
    }
    return currentItem;
}

- (IBAction)deleteFolder:(id)sender{
    ECSubscriptionItem *clickedItem = [self getCurrentSubscriptionItem];

    NSAssert(clickedItem != nil, @"clickedItem should not be nil");
    
    NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];

    if ([clickedItem isKindOfClass:[ECSubscriptionFeed class]]) {
		[alert setMessageText:@"Are you sure you want to delete this subscription?"];
	} else if ([clickedItem isKindOfClass:[ECSubscriptionFolder class]]) {
		[alert setMessageText:@"Are you sure you want to delete this folder?\nAll the subscriptions it contains will be REMOVED at the same time!"];
	} else { // should never happen, but handle it anyway
        [alert setMessageText:@"Are you sure you want to delete this?"];
	}
	
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(sourceListDeleteAlertDidEnd:returnCode:contextInfo:) contextInfo:clickedItem];
	[alert release];

}

- (void)sourceListDeleteAlertDidEnd:(NSAlert *)theAlert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	
	if (returnCode == NSAlertFirstButtonReturn) {
		
		ECSubscriptionItem *clickedItem = [(ECSubscriptionItem *)contextInfo retain];
		
		[self deleteSourceListItem:clickedItem];
		
		[clickedItem release];
	}
}

- (void)deleteSourceListItem:(ECSubscriptionItem *)item {
	
	if (item == nil) {
		return;
	}
	
    ECSubscriptionFolder *folder = (ECSubscriptionFolder *)item;
    [ECDatabaseController deleteFolder:folder];
	//TODO: if the selected tab is for the item we are deleting (or a descendent), change it to be for new items
	
    //TODO: change badgeValue
//	if ([item badgeValue] > 0) {
//		[SyndicationAppDelegate changeBadgeValuesBy:([item badgeValue] * -1) forAncestorsOfItem:item];
//		[self changeNewItemsBadgeValueBy:([item badgeValue] * -1)];
//	}
	
    //TODO: updateViewForSourceListItem
    //	[self closeAllTabsForSourceListItem:item];
	
    [self didDeleteFolder:(ECSubscriptionFolder *)item];
		
    [[subscriptionSubscriptions children] removeObject:item];
	
	[self refreshSubscriptionsView];
//	[self restoreSourceListSelections];
}

- (void)didDeleteFolder:(ECSubscriptionFolder *)folder {
	if (folder != nil) {
		for (ECSubscriptionItem *child in [folder children]) {
            [self didDeleteFeed:(ECSubscriptionFeed *)child];
		}
	}
}

- (void)didDeleteFeed:(ECSubscriptionFeed *)feed {
	if (feed != nil && [feed dbId] > 0) {
		[[ECRequestController getSharedInstance] removeFromRequestForFeed:feed];
	}
}

- (IBAction)refreshSubscriptions:(id)sender{
    [[ECRequestController getSharedInstance] queueAllFeedsSyncRequest:subscriptionSubscriptions];
}

- (IBAction)addSubscription:(id)sender{
    [addFeedController clearTextField];
    [addFeedController reloadDataOfPopUp];
	[addFeedController showDialog:self];
}

- (IBAction)addSubscriptionForSure:(id)sender{
    
    NSString *url = [addFeedController getUrl];
	ECSubscriptionFolder *folder = nil;
    
	if (url != nil && [url length] > 0) {
		[self addSubscriptionForUrlString:url toFolder:folder];
	}
    
	[addFeedController hideDialog:nil];
}

- (void)addSubscriptionForUrlString:(NSString *)url toFolder:(ECSubscriptionFolder *)folder{
	url = [url ecTrimmedString];
	
	// add http:// to the beginning if necessary
	NSURL *urlTest = [NSURL URLWithString:url];
	
	if ([urlTest scheme] == nil) {
		NSString *newUrl = [NSString stringWithFormat:@"http://%@", url];
		NSURL *newUrlTest = [NSURL URLWithString:newUrl];
		
		if (newUrlTest != nil && [[newUrlTest scheme] isEqual:@"http"]) {
			url = newUrl;
		}
	}
	
    [ECDatabaseController addSubscriptionForUrlString:url toFolder:folder refreshImmediately:YES];
}

- (void)iconRefreshOperation:(ECIconRefreshOperation *)refreshOp refreshedFeed:(ECSubscriptionFeed *)feed foundIcon:(NSImage *)icon {
	
	[feed setIcon:icon];
	
    [self redrawSourceListItem:feed];
	
	[self markIconAsRefreshedAndStartTimer:feed];
}

- (void)redrawSourceListItem:(ECSubscriptionItem *)item {
	NSInteger itemRow = [subsView rowForItem:item];
	
	if (itemRow >= 0) {
		[subsView setNeedsDisplayInRect:[subsView frameOfCellAtColumn:0 row:itemRow]];
	}
}

- (void)markIconAsRefreshedAndStartTimer:(ECSubscriptionFeed *)feed {
	
	[feed setIconLastRefreshed:[NSDate date]];
	
	if ([feed icon] != nil) {
		@try {
			NSData *faviconData = [NSArchiver archivedDataWithRootObject:[feed icon]];
			[[ECRequestController getSharedInstance] runDatabaseUpdateOnBackgroundThread:@"UPDATE feed SET Icon=?, IconLastRefreshed=? WHERE Id=?", faviconData, [feed iconLastRefreshed], [NSNumber numberWithInteger:[feed dbId]], nil];
		} @catch (...) {
			[[ECRequestController getSharedInstance] runDatabaseUpdateOnBackgroundThread:@"UPDATE feed SET Icon=NULL, IconLastRefreshed=? WHERE Id=?", [feed iconLastRefreshed], [NSNumber numberWithInteger:[feed dbId]], nil];
		}
	} else {
		[[ECRequestController getSharedInstance] runDatabaseUpdateOnBackgroundThread:@"UPDATE feed SET Icon=NULL, IconLastRefreshed=? WHERE Id=?", [feed iconLastRefreshed], [NSNumber numberWithInteger:[feed dbId]], nil];
	}
    
    [[ECRequestController getSharedInstance] addTimerOfIconRequestForFeed:feed forTimeInterval:ICON_REFRESH_INTERVAL];
	
}

- (void)refreshSubscriptionsView{
    [subsView reloadData];
    [subsView setNeedsDisplay:YES];
}

#pragma mark CLFeedParserOperationDelegate
- (void)feedParserOperationFoundNewPostsForFeed:(ECSubscriptionFeed *)feed {
	NSArray *postsToAddToDB = [feed postsToAddToDB];
	NSInteger numberOfUnread = 0;
	
	for (ECPost *post in postsToAddToDB) {
		if ([post isRead] == NO) {
			numberOfUnread++;
		}
	}
	
	if (numberOfUnread > 0) {
		[feed setBadgeValue:([feed badgeValue] + numberOfUnread)];
//		[SyndicationAppDelegate changeBadgeValuesBy:numberOfUnread forAncestorsOfItem:feed];
//		[self changeNewItemsBadgeValueBy:numberOfUnread];
	}
	
	[self processNewPosts:postsToAddToDB forFeed:feed];
}

- (void)feedParserOperationFoundTitleForFeed:(ECSubscriptionFeed *)feed {
	[self subscriptionsViewDidRenameItem:feed];
}

- (void)feedParserOperationFoundWebsiteLinkForFeed:(ECSubscriptionFeed *)feed {
    [[ECRequestController getSharedInstance] queueIconRefreshOperationFor:feed];
}
#pragma mark -

- (void)processNewPosts:(NSArray *)newPosts forFeed:(ECSubscriptionFeed *)feed {
	
	if ([newPosts count] > 0) {
		
		NSArray *reverseNewItems = [[newPosts reverseObjectEnumerator] allObjects];
		
		// add them to the db
			
        [ECDatabaseController addToDatabaseForPosts:reverseNewItems forFeed:feed];
	}
	
//	[fself updateMenuItems];
}

- (void)subscriptionsViewDidRenameItem:(ECSubscriptionItem *)item {
	
	//[self sortSourceList];
	[self refreshSubscriptionsView];
//	[self restoreSourceListSelections];
	
//    // update the label for any open tabs
//    if ([subsView sourceListItem] == item) {
//        [[windowController classicViewContainer] setNeedsDisplay:YES];
//    }
    
    // refresh classic views (so feed titles can update there too)
//    [[classicView tableView] setNeedsDisplay:YES];
    
	
	if ([item isKindOfClass:[ECSubscriptionFeed class]]) {
		ECSubscriptionFeed *feed = (ECSubscriptionFeed *)item;
		[[ECRequestController getSharedInstance] runDatabaseUpdateOnBackgroundThread:@"UPDATE feed SET Title=? WHERE Id=?", [feed title], [NSNumber numberWithInteger:[feed dbId]], nil];
	} else if ([item isKindOfClass:[ECSubscriptionFolder class]]) {
		ECSubscriptionFolder *folder = (ECSubscriptionFolder *)item;
		[[ECRequestController getSharedInstance] runDatabaseUpdateOnBackgroundThread:@"UPDATE folder SET Title=? WHERE Id=?", [folder title], [NSNumber numberWithInteger:[folder dbId]], nil];
	}
}

#pragma mark CLSourceList context menu
- (void)menuNeedsUpdate:(NSMenu *)menu {
	
	if (menu == subsViewContextMenu) {
		ECSubscriptionItem *clickedItem = [subsView itemAtRow:[subsView clickedRow]];
		
		[menu removeAllItems];
		
		if ([clickedItem isGroupItem]) {
			return;
		}
        //TODO:menu item
		NSMenuItem *refreshItem = [[NSMenuItem alloc] initWithTitle:@"Refresh" action:@selector(subscriptionsRefresh:) keyEquivalent:@""];
        [refreshItem setTarget:self];
		[menu addItem:refreshItem];
		[refreshItem release];
		
		NSMenuItem *markReadItem = [[NSMenuItem alloc] initWithTitle:@"Mark All As Read" action:@selector(sourceListMarkAllAsRead:) keyEquivalent:@""];
        [markReadItem setTarget:self];
		[menu addItem:markReadItem];
		[markReadItem release];
		
		if ([clickedItem isEditable]) {
			[menu addItem:[NSMenuItem separatorItem]];
			
			NSMenuItem *editItem = nil;
            NSMenuItem *deleteItem = nil;
			
            if ([clickedItem isKindOfClass:[ECSubscriptionFeed class]]) {
                deleteItem = [[NSMenuItem alloc] initWithTitle:@"Delete Feed"
                                                        action:@selector(deleteFolder:)
                                                 keyEquivalent:@""];

            } else{
                NSString *editTitle = [NSString stringWithFormat:@"Rename \"%@\"", [clickedItem title]];;
                editItem = [[NSMenuItem alloc] initWithTitle:editTitle
                                                      action:@selector(editFolder:)
                                               keyEquivalent:@""];
                
                deleteItem = [[NSMenuItem alloc] initWithTitle:@"Delete Folder"
                                                        action:@selector(deleteFolder:)
                                                 keyEquivalent:@""];
            }
            
            [editItem setTarget:self];
			[menu addItem:editItem];
			[editItem release];

            [deleteItem setTarget:self];
            [menu addItem:deleteItem];
            [deleteItem release];
		}
        [menu update];
	}
}

- (void)subscriptionsRefresh:(NSMenuItem *)sender {
	NSInteger clickedRow = [subsView clickedRow];
	ECSubscriptionItem *clickedItem = [subsView itemAtRow:clickedRow];
	
	if (clickedItem == subscriptionNewItems) {
		[[ECRequestController getSharedInstance] queueAllFeedsSyncRequest:subscriptionSubscriptions];
	} else if (clickedItem == subscriptionStarredItems) {
		
	} else {
        if ([clickedItem isKindOfClass:[ECSubscriptionFeed class]]) {
            [[ECRequestController getSharedInstance] queueSyncRequestForSpecificFeeds:[NSMutableArray arrayWithObject:(ECSubscriptionFeed *)clickedItem]];
        } else if ([clickedItem isKindOfClass:[ECSubscriptionFolder class]]) {
            [[ECRequestController getSharedInstance] queueSyncRequestForSpecificFeeds:[NSMutableArray arrayWithObject:[(ECSubscriptionFeed *)clickedItem children]]];
        }
	}
}

@end
