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
        
        NSRect fromRect = NSMakeRect(0, 0, targetWidth, targetHeight);
        NSSize scaleSize = targetSize;
        if (width > height) {
            scaleSize = NSMakeSize(width * targetHeight / height, targetHeight);
            fromRect = NSMakeRect(scaleSize.width/2 - scaleSize.height/2, 0, targetWidth, targetHeight);
        } else if (width < height){
            scaleSize = NSMakeSize(targetWidth, height * targetWidth / width);
            fromRect = NSMakeRect(0, scaleSize.width/2 - scaleSize.height/2, targetWidth, targetHeight);
        }
        
        NSImage *scaleImage = [[NSImage alloc] initWithSize:scaleSize];
        [scaleImage lockFocus];
        [sourceImage drawInRect: NSMakeRect(0, 0, scaleSize.width, scaleSize.height)
                         fromRect: NSZeroRect
                        operation: NSCompositeSourceOver
                         fraction: 1.0];
        [scaleImage unlockFocus];

        newImage = [[NSImage alloc] initWithSize:targetSize];
        [newImage lockFocus];
        [scaleImage drawInRect: NSMakeRect(0, 0, targetWidth, targetWidth)
                       fromRect: fromRect
                      operation: NSCompositeCopy
                       fraction: 1.0];
        [newImage unlockFocus];
        
        [scaleImage release];
    }
    return [newImage autorelease];
}

- (NSImage*)imageByScalingToSize:(NSSize)targetSize{
    NSImage* sourceImage = self;

    
    NSRect targetFrame = NSMakeRect(0, 0, targetSize.width, targetSize.height);
    NSImage*  targetImage = [[NSImage alloc] initWithSize:targetSize];
    NSImageRep *sourceImageRep =
    [sourceImage bestRepresentationForRect:targetFrame
                                   context:nil
                                     hints:nil];

    [targetImage lockFocus];
    
    [sourceImageRep drawInRect: targetFrame];

    [targetImage unlockFocus];
    
    return targetImage;
}


@end
