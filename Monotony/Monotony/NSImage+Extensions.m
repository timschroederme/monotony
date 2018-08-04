//
//  NSImage+Extensions.m
//  Monotony
//
//  Created by Tim Schröder on 17.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "NSImage+Extensions.h"

@implementation NSImage (Extensions)

// Creates BitmapImageRep from Image
- (NSBitmapImageRep*) bitmap
{
	NSSize size = [self size];
	int rowBytes = ((int)(ceil(size.width)) * 4 + 0x0000000F) & ~0x0000000F; // 16-byte aligned
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil 
                                                                         pixelsWide:size.width 
                                                                         pixelsHigh:size.height 
                                                                      bitsPerSample:8
                                                                    samplesPerPixel:4
                                                                           hasAlpha:YES
                                                                           isPlanar:NO 
                                                                     colorSpaceName:NSCalibratedRGBColorSpace
                                                                       bitmapFormat:0
                                                                        bytesPerRow:rowBytes 
                                                                       bitsPerPixel:32];
	if (imageRep == NULL) return nil;
	NSGraphicsContext* imageContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:imageContext];
	[self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	[NSGraphicsContext restoreGraphicsState];
	return imageRep;
}

// Adds Alpha Channel to Image
-(NSImage*)processAlpha
{
    float alphaThreshold = 248.0;
    
    NSBitmapImageRep *bitmap = [self bitmap];
    if (!bitmap) return self;
    
    [bitmap setAlpha:YES];
    NSSize imageSize = [bitmap size];
    
    int samples = imageSize.height * [bitmap bytesPerRow];
    unsigned char *bitmapData = [bitmap bitmapData];
    NSInteger samplesPerPixel = [bitmap samplesPerPixel];
    
    int startSample = [bitmap bitmapFormat] & NSAlphaFirstBitmapFormat ? 1 : 0;
    
    for (long i = startSample; i < samples; i = i + samplesPerPixel) {
        
        if (bitmapData[i] > alphaThreshold && bitmapData[i + 1] > alphaThreshold && bitmapData[i + 2] > alphaThreshold) {
            bitmapData[i+3] = 0.0;
        }
    }
    
    // Graustufen
    /*
    [bitmap colorizeByMappingGray:0.5
                          toColor:[NSColor colorWithCalibratedWhite:0.50 alpha:1.0]
                     blackMapping:[NSColor colorWithCalibratedWhite:0.03 alpha:1.0]
                     whiteMapping:[NSColor colorWithCalibratedWhite:0.97 alpha:1.0]];
     */
    
    // Fertiges Bild zurückgeben
    NSImage *newImage = [[NSImage alloc] initWithSize:[bitmap size]];
    [newImage addRepresentation:bitmap];
    return newImage;
}

-(NSImage*)addBackground
{
    NSSize size = [self size];
    if (size.width >= 32.0) return self;
    
    float offset = (32.0-size.width)/2.0;
    NSImage *outputImage = [[NSImage imageNamed:@"iconbackground32.png"] copy];
    [outputImage lockFocus];
    
    [self drawAtPoint:NSMakePoint(offset, offset) 
             fromRect:NSMakeRect(0.0, 0.0, size.width, size.height) 
            operation:NSCompositeSourceOver 
             fraction:1.0];
    
    [outputImage unlockFocus];
    return (outputImage);
}


@end
