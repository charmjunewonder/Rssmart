//
//  ECHTMLFilter.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@interface ECHTMLFilter : NSObject <NSXMLParserDelegate>

+ (NSString *)extractPlainTextFromString:(NSString *)string;
+ (NSString *)extractPlainTextFromNode:(NSXMLNode *)node;
+ (NSString *)cleanUrlString:(NSString *)url;
+ (NSString *)extractFirstImageUrlFromString:(NSString *)htmlString;

@end
