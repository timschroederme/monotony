//
//  NSURL+Extensions.h
//  Monotony
//
//  Created by Tim Schröder on 17.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

/** This category on the NSURL class provides some handy extensions to work with web URLs. */

@interface NSURL (Extensions)

/** Adds a URL scheme to a URL, if it isn't already part of the URL.
 @return Normalized URL. 
 */
- (NSURL*) addScheme;

/** This method checks if two URLs are pointing to the same location.
 @return Returns YES if the two URLs are pointing to the same location, otherwise NO.
 @param otherURL The URL to compare to the receiver.
 */
- (BOOL) isEqualToURL:(NSURL*)otherURL;

/** This method composes an absolute URL from the receiver.
 @return Returns an absolute URL.
 @param host The host name which is to be added to the relative URL.
 */
- (NSURL*) expandRelativeLinkWithHost:(NSString*)host;

@end
