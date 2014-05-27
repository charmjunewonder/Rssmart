//
//  ECTableViewTextFieldCell.m
//  Rssmart
//
//  Created by charmjunewonder on 4/29/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECTableViewTextFieldCell.h"
#import "ECConstants.h"
#import "ECPost.h"
#import "ECTableView.h"
#import "NSDate+ECAdditions.h"
#import "GTMNSString+HTML.h"
#import "ECHTMLFilter.h"
#import "NSImage+ECScaling.h"

@implementation ECTableViewTextFieldCell

@synthesize delegate;
@synthesize rowIndex;
@synthesize tableViewReference;

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	
	BOOL isKeyWindow = [[tableViewReference window] isKeyWindow];
	BOOL isFirstResponder = ((NSResponder *)tableViewReference == [[tableViewReference window] firstResponder]);
	BOOL isSelectedRow = [[tableViewReference selectedRowIndexes] containsIndex:rowIndex];
	
	NSFont *font = [NSFont fontWithName:@"HelveticaNeue" size:13];
	NSFont *boldFont = [NSFont fontWithName:@"HelveticaNeue-Medium" size:13];
	
	ECPost *post = [delegate tableViewTextFieldCell:self postForRow:rowIndex];
	
	if (post == nil) {
		return;
	}
	//TODO: move to feedparseoperation
    
	NSRect titleRect = [self titleRectForBounds:cellFrame];
	
    /************************ firstImage ************************/
    NSRect imageRect = NSMakeRect(titleRect.origin.x + 6, titleRect.origin.y + 15, 50, 50);
    [[post firstImage] drawInRect:imageRect];

    /************************ unreadDot ************************/
    NSImage *unreadDot;
	if ([post isRead] == NO) {
        NSString *unreadDotName = [[NSBundle mainBundle] pathForResource:@"dot" ofType:@"png"];
        unreadDot = [[NSImage alloc] initWithContentsOfFile:unreadDotName];
        [unreadDot setFlipped:YES];
	} else {
        NSString *readDotName = [[NSBundle mainBundle] pathForResource:@"read_dot" ofType:@"png"];
        unreadDot = [[NSImage alloc] initWithContentsOfFile:readDotName];
        [unreadDot setFlipped:YES];
    }
    
    imageRect = NSMakeRect(titleRect.origin.x + 17, titleRect.origin.y + 3.5, 9, 9);
    [unreadDot drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

    /************************ starIcon ************************/
    NSImage *starIcon = nil;

    if ([post isStarred] == NO) {
        NSString *unstarredIconName = [[NSBundle mainBundle] pathForResource:@"star_small" ofType:@"png"];
        starIcon = [[NSImage alloc] initWithContentsOfFile:unstarredIconName];
        [starIcon setFlipped:YES];
	} else{
        NSString *starredIconName = [[NSBundle mainBundle] pathForResource:@"star_full_small" ofType:@"png"];
        starIcon = [[NSImage alloc] initWithContentsOfFile:starredIconName];
        [starIcon setFlipped:YES];
    }
    
    imageRect = NSMakeRect(titleRect.origin.x + 30, titleRect.origin.y + 0, 15, 15);
    [starIcon drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
	titleRect = NSMakeRect(titleRect.origin.x + 22, titleRect.origin.y + 1, titleRect.size.width - 50, 20);
    
    /************************ date ************************/
	NSString *dateString = [[post received] ecStringForDisplay];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	[attributes setObject:font forKey:NSFontAttributeName];
	
	if (isSelectedRow && (isKeyWindow == NO || isFirstResponder == NO)) {
		[attributes setObject:[NSColor colorWithCalibratedWhite:0.4 alpha:1.0] forKey:NSForegroundColorAttributeName];
	} else {
		[attributes setObject:[NSColor colorWithCalibratedWhite:0.015 alpha:0.5] forKey:NSForegroundColorAttributeName];
	}
	
	NSAttributedString *attributedDateString = [[NSAttributedString alloc] initWithString:dateString attributes:attributes];
	
	NSRect dateRectSize = [dateString boundingRectWithSize:NSZeroSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes];
	NSInteger dateRectWidth = (NSInteger)ceil(dateRectSize.size.width);
	NSRect dateRect = NSMakeRect(13, titleRect.origin.y + 60, dateRectWidth, titleRect.size.height);
	
	[attributedDateString drawInRect:dateRect];
	[attributedDateString release];
	
    /************************ feed title ************************/
	NSString *feedTitle = [post feedTitle];
	
	if (feedTitle == nil) {
		feedTitle = [post feedUrlString];
	}
	
	if (feedTitle == nil) {
		feedTitle = @"";
	}
	
	[attributes setObject:boldFont forKey:NSFontAttributeName];
	
	if (TABLE_VIEW_SELECTION_STYLE == CLTableViewImageStyle && isSelectedRow) {
		[attributes setObject:[NSColor colorWithCalibratedWhite:0.945 alpha:1.0] forKey:NSForegroundColorAttributeName];
	} else {
		[attributes setObject:[NSColor colorWithCalibratedWhite:0.015 alpha:1.0] forKey:NSForegroundColorAttributeName];
	}
	
	NSRect titleDrawRect = NSMakeRect(titleRect.origin.x + 40, titleRect.origin.y - 5, titleRect.size.width - 7, titleRect.size.height);
	
	[feedTitle drawWithRect:titleDrawRect options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin) attributes:attributes];
	
    /************************ post title ************************/
	NSString *postTitle = [post title];
	
	if (postTitle == nil || [postTitle length] == 0) {
		postTitle = @"(Untitled)";
	}
	
	NSRect bylineRect = NSMakeRect(titleRect.origin.x + 40, titleRect.origin.y + 14, titleRect.size.width, titleRect.size.height);
	
	[attributes setObject:font forKey:NSFontAttributeName];
	
	[postTitle drawWithRect:bylineRect options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin) attributes:attributes];
	
    /************************ summary ************************/
	NSString *summary = [post plainTextContent];
	
	if (summary == nil) {
		summary = @"";
	}
	
	summary = [[summary componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
	
	NSRect summaryRect = NSMakeRect(titleRect.origin.x + 40, titleRect.origin.y + 35, titleRect.size.width - 7, 39);
	
	attributes = [NSMutableDictionary dictionary];
	[attributes setObject:font forKey:NSFontAttributeName];
	
	if (TABLE_VIEW_SELECTION_STYLE == CLTableViewImageStyle && isSelectedRow) {
		[attributes setObject:[NSColor colorWithCalibratedWhite:0.845 alpha:1.0] forKey:NSForegroundColorAttributeName];
	} else {
		[attributes setObject:[NSColor colorWithCalibratedWhite:0.38 alpha:1.0] forKey:NSForegroundColorAttributeName];
	}
	
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setMaximumLineHeight:16.0];
	[attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
	[paragraphStyle release];
	
	[summary drawWithRect:summaryRect options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin) attributes:attributes];
}

@end
