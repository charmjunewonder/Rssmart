//
//  ECStringHelper.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@interface ECStringHelper : NSObject

+ (NSString *)stringFromData:(NSData *)data withPossibleEncoding:(NSStringEncoding)stringEncoding;

@end
