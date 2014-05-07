//
//  NSDictionary+Merge.m
//  Terms
//
//  Created by charmjunewonder on 5/7/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "NSDictionary+ECMerge.h"

@implementation NSDictionary (ECMerge)

+ (NSDictionary *) dictionaryByMerging: (NSDictionary *) dict1 with: (NSDictionary *) dict2 {
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:dict1];
    
    [dict2 enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if (![dict1 objectForKey:key]) {
            [result setObject: obj forKey: key];
        } else{
            CGFloat a = [[dict1 objectForKey:key] floatValue];
            CGFloat b = [[dict2 objectForKey:key] floatValue];
            [result setObject:[NSNumber numberWithFloat:a+b] forKey:key];
        }
    }];
    
    return (NSDictionary *) [[result mutableCopy] autorelease];
}
- (NSDictionary *) dictionaryByMergingWith: (NSDictionary *) dict {
    return [[self class] dictionaryByMerging: self with: dict];
}

@end
