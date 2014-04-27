//
//  ECXMLParser.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#include <libxml/xmlmemory.h>

@class ECXMLNode;

@interface ECXMLParser : NSObject

+ (ECXMLNode *)parseString:(NSString *)xmlString;
+ (void)parseLibNode:(xmlNodePtr)libNode intoObjectNode:(ECXMLNode *)objectNode;

@end
