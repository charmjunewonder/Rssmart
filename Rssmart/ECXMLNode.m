//
//  ECXMLNode.m
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECXMLNode.h"
#import "NSString+ECAddition.h"

@implementation ECXMLNode

@synthesize name;
@synthesize nameSpace;
@synthesize content;
@synthesize attributes;
@synthesize children;
@synthesize type;

- (id)init {
	self = [super init];
	if (self != nil) {
		[self setAttributes:[NSMutableDictionary dictionary]];
		[self setChildren:[NSMutableArray array]];
	}
	return self;
}

- (void)dealloc {
	[name release];
	[nameSpace release];
	[content release];
	[attributes release];
	[children release];
	
	[super dealloc];
}

+ (ECXMLNode *)xmlNode {
	return [[[ECXMLNode alloc] init] autorelease];
}

- (NSString *)combinedTextValue {
	if (type == ECXMLTextNode) {
		return [NSString stringWithString:content];
	}
	
	NSMutableString *combinedTextValue = [NSMutableString string];
	
	for (ECXMLNode *child in children) {
		NSString *textValue = [child combinedTextValue];
		
		if (textValue != nil) {
			[combinedTextValue appendString:textValue];
		}
	}
	
	return [combinedTextValue ecTrimmedString];
}

@end
