//
//  NSImage+Extensions.h
//  Monotony
//
//  Created by Tim Schröder on 17.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <AppKit/AppKit.h>

/** This category on the NSImage class provides some additional methods for image manipulation.
 */

@interface NSImage (Extensions)

/** This method converts the receiver into a new NSBitmapImageRep instance.
 @return A NSBitmapImageRep instance created from the receiver, or nil if creation didn't work.
 */
- (NSBitmapImageRep*) bitmap;

/** This method adds an alpha channel to a copy of the receiver by interpreting all white areas as transparent areas.
 @return A copy of the receiver with added alpha channel.
 */
- (NSImage*) processAlpha;

/** This methods adds a custom background image to a copy of the receiver. 
 @warning The methods only works if the receiver is not bigger than 32x32 pixels, and it needs to have the background image to add as an external resource.
 @return A copy of the receiver with added background image.
 */
- (NSImage*) addBackground;

@end
