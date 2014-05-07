//
//  NSDictionary+Merge.h
//  Terms
//
//  Created by charmjunewonder on 5/7/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@interface NSDictionary (ECMerge)

+ (NSDictionary *) dictionaryByMerging: (NSDictionary *) dict1 with: (NSDictionary *) dict2;
- (NSDictionary *) dictionaryByMergingWith: (NSDictionary *) dict;

@end
