//
//  NSImage+ProportionalScaling.h
//  Rssmart
//
//  Created by charmjunewonder on 5/26/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (ECScaling)
- (NSImage*)imageBySelectivelyScalingToSize:(NSSize)targetSize;
@end
