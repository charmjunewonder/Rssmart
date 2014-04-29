//
//  ECWebView.m
//  Rssmart
//
//  Created by charmjunewonder on 4/29/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECWebView.h"
#import "ECConstants.h"

@implementation ECWebView

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self != nil) {
		[self setPreferencesIdentifier:@"rssmart"];
		[[self preferences] setMinimumFontSize:9];
		[[self preferences] setDefaultFontSize:16];
		[[self preferences] setDefaultFixedFontSize:16];
		
		[[self preferences] setJavaEnabled:YES];
		[[self preferences] setJavaScriptEnabled:YES];
		[[self preferences] setJavaScriptCanOpenWindowsAutomatically:YES];
		[[self preferences] setPlugInsEnabled:YES];
		
		[[self preferences] setAllowsAnimatedImageLooping:YES];
		[[self preferences] setAllowsAnimatedImages:YES];
		[[self preferences] setLoadsImagesAutomatically:YES];
		
		[[self preferences] setCacheModel:WebCacheModelDocumentViewer];
		[[self preferences] setUsesPageCache:NO];
	}
	
	return self;
}

@end
