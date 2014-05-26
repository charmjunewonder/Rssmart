//
//  NSImage+ProportionalScaling.m
//  Rssmart
//
//  Created by charmjunewonder on 5/26/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "NSImage+ECScaling.h"

@implementation NSImage (ECScaling)

- (NSImage*)imageBySelectivelyScalingToSize:(NSSize)targetSize{
    NSImage* sourceImage = self;
    NSImage* newImage = nil;
    
    if ([sourceImage isValid]){
        NSSize imageSize = [sourceImage size];
        float width  = imageSize.width;
        float height = imageSize.height;
        
        float targetWidth  = targetSize.width;
        float targetHeight = targetSize.height;
        
        NSRect fromRect = NSMakeRect(0, 0, width, height);
        NSRect rect = fromRect;
        if (width > height) {
            fromRect = NSMakeRect(width/2 - height/2, 0, height, height);
            rect = NSMakeRect(0, 0, height, height);
        } else if (width < height){
            rect = NSMakeRect(0, 0, width, width);
        }
        NSImage *selectedImage = [[NSImage alloc] initWithSize:fromRect.size];
        [selectedImage lockFocus];
        [sourceImage drawInRect: rect
                       fromRect: fromRect
                      operation: NSCompositeCopy
                       fraction: 1.0];
        [selectedImage unlockFocus];

        newImage = [[NSImage alloc] initWithSize:targetSize];
        [newImage lockFocus];
        [selectedImage drawInRect: NSMakeRect(0, 0, targetWidth, targetHeight)
                       fromRect: NSZeroRect
                      operation: NSCompositeSourceOver
                       fraction: 1.0];
        [newImage unlockFocus];
    }
    return [newImage autorelease];
}

@end
