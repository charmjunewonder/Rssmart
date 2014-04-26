//
//  ECUrlFetcher.h
//  Rssmart
//
//  Created by charmjunewonder on 4/27/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//


@interface ECUrlFetcher : NSObject

+ (NSData *)fetchUrlString:(NSString *)urlString postData:(NSData *)postData returnNilOnFailure:(BOOL)nilOnFail urlResponse:(NSURLResponse **)urlResponse;
+ (NSURLConnection *)fetchUrlString:(NSString *)urlString delegate:(id)delegate;
+ (BOOL)isSuccessStatusCode:(NSInteger)code;

@end
