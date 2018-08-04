//
//  NSWorkspace+Extensions.h
//  Monotony
//
//  Created by Tim Schröder on 17.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <AppKit/AppKit.h>

/** Some handy extensions to the NSWorkspace class.
 */

@interface NSWorkspace (Extensions)

/** Returns the path of the app's working directory.
 @return NSString instance containing the path of the app's working directory.
 */
+(NSString*)appDir;

/** Returns the path of the old (< Monotony 1.2) feed file.
 @return NSString instance containing the file path.
 */
+(NSString*)oldFeedPath;

@end
