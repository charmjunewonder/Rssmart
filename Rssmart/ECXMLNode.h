//
//  ECXMLNode.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

typedef enum {ECXMLElementNode, ECXMLTextNode} ECXMLNodeType;

@interface ECXMLNode : NSObject

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *nameSpace;
@property (retain, nonatomic) NSString *content;
@property (retain, nonatomic) NSMutableDictionary *attributes;
@property (retain, nonatomic) NSMutableArray *children;
@property (assign, nonatomic) ECXMLNodeType type;

+ (ECXMLNode *)xmlNode;

- (NSString *)combinedTextValue;

@end
