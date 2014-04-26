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

#define SOURCE_LIST_DRAG_TYPE @"SourceListDragType"

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
 * then postsview will change
 */
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	ECSubscriptionItem *selectedItem = [subsView itemAtRow:[subsView selectedRow]];
	
//	if (selectedItem != nil) {
//		if ([classicView sourceListItem] != selectedItem) {
//            [self openItemInCurrentTab:selectedItem orQuery:nil];
//		}
//	}
	
	[self setSubscriptionSelectedItem:selectedItem];
}
#pragma mark -

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


@end
