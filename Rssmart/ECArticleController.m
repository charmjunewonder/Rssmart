//
//  ECArticleController.m
//  Rssmart
//
//  Created by charmjunewonder on 4/29/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECArticleController.h"
#import "ECConstants.h"
#import "ECPost.h"
#import "ECSubscriptionItem.h"
#import "ECTableView.h"
#import "ECWebView.h"
#import "GTMNSString+HTML.h"

@implementation ECArticleController

@synthesize webView;
@synthesize displayedPost;

static ECArticleController *_sharedInstance = nil;

+ (ECArticleController *)getSharedInstance
{
    if(_sharedInstance == nil)
        @synchronized(self) {
            if(_sharedInstance == nil)
                _sharedInstance = [[ECArticleController alloc] init];
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

- (void)updateUsingPost:(ECPost *)post headlineFontName:(NSString *)headlineFontName headlineFontSize:(CGFloat)headlineFontSize bodyFontName:(NSString *)bodyFontName bodyFontSize:(CGFloat)bodyFontSize {
	
	[self setDisplayedPost:post];
	
	NSMutableString *htmlString = [NSMutableString string];
	
	[htmlString appendString:@"<html><head>"];
	[htmlString appendString:CSS_FORMAT_STRING];
	[htmlString appendString:@"<style type=\"text/css\">#post {margin: 15px 24px 25px}</style>"];
	[htmlString appendFormat:@"<style type=\"text/css\">body {font: %fpt/1.35em '%@', sans-serif} th, td {font-size: %fpt} #postHeadline {font: %fpt '%@', sans-serif}</style>", bodyFontSize, bodyFontName, bodyFontSize, headlineFontSize, headlineFontName];
	[htmlString appendString:@"</head><body>"];
	
	[htmlString appendString:@"<div id=\"post\">"];
	[htmlString appendString:@"<div id=\"postContent\">"];
	
	NSString *title = [post title];
	
	if (title == nil || [title length] == 0) {
		title = @"(Untitled)";
	}
	
	title = [title gtm_stringByEscapingForHTML];
	
	[htmlString appendString:@"<div id=\"postHeadline\">"];
	
	if ([post link] != nil) {
		[htmlString appendFormat:@"<a href=\"%@\">%@</a>", [post link], title];
	} else {
		[htmlString appendString:title];
	}
	
	[htmlString appendString:@"</div>"];
	
	BOOL hasFeedTitle = ([post feedTitle] != nil && [[post feedTitle] length] > 0);
	BOOL hasAuthor = ([post author] != nil && [[post author] length] > 0);
	
	[htmlString appendString:@"<div class=\"postMeta\">"];
	
	if (hasFeedTitle) {
		[htmlString appendString:[[post feedTitle] gtm_stringByEscapingForHTML]];
	}
	
	if (hasAuthor) {
		if (hasFeedTitle) {
			[htmlString appendString:@" · "];
		}
		
		[htmlString appendString:[[post author] gtm_stringByEscapingForHTML]];
	}
	
	if (hasFeedTitle || hasAuthor) {
		[htmlString appendString:@" · "];
	}
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *dateString = [dateFormatter stringFromDate:[post received]];
	[dateFormatter release];
	
	[htmlString appendString:dateString];
	
	[htmlString appendString:@"</div>"];
	
	[htmlString appendString:@"<div class=\"fakeHR\"></div>"];
	
	if ([post content] != nil) {
		[htmlString appendString:[post content]];
	}
	
	[htmlString appendString:@"</div>"];
	
	if ([[post enclosures] count] > 0) {
		[htmlString appendString:@"<div id=\"postEnclosures\">"];
		
		if ([[post enclosures] count] == 1) {
			[htmlString appendString:@"<div id=\"postEnclosureTitle\">ENCLOSURE</div>"];
		} else {
			[htmlString appendString:@"<div id=\"postEnclosureTitle\">ENCLOSURES</div>"];
		}
	}
	
	for (NSString *enclosure in [post enclosures]) {
		NSString *enclosureDisplay = enclosure;
		NSURL *enclosureUrl = [NSURL URLWithString:enclosure];
		
		if (enclosureUrl != nil && [enclosureUrl lastPathComponent] != nil) {
			enclosureDisplay = [enclosureUrl lastPathComponent];
		}
		
		[htmlString appendString:[NSString stringWithFormat:@"<div class=\"postEnclosure\"><a href=\"%@\">%@</a></div>", enclosure, enclosureDisplay]];
	}
	
	if ([[post enclosures] count] > 0) {
		[htmlString appendString:@"</div>"];
	}
	
	[htmlString appendString:@"</div>"];
	[htmlString appendString:@"</body></html>"];
	
	[[webView mainFrame] loadHTMLString:htmlString baseURL:nil];
}

@end
