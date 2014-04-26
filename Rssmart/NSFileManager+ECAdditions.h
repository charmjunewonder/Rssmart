//
//  NSFileManager+ECAdditions.h
//  Rssmart
//
//  Created by charmjunewonder on 4/26/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@interface NSFileManager (ECAdditions)

- (NSString *)ecApplicationSupportDirectory;
- (NSString *)ecRssmartSupportDirectory;
- (void)ecCopyLiteDirectoryIfItExistsAndRegularDirectoryDoesnt;

@end
