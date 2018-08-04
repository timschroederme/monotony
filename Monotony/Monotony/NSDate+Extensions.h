//
//  NSDate+Extensions.h
//  Monotony
//
//  Created by Tim Schröder on 17.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

/** This extension of the NSDate class contains some utility methods to convert NSDate instances to and from internet date strings */

@interface NSDate (Extensions)

/** Creates a NSDate instance from an RFC1123 date string.
 @result A new NSDate instance.
 @param value_ the RFC1123 encoded date string.
 */
+(NSDate*)dateFromRFC1123:(NSString*)value_;

/** Converts the receiver to an RFC1123 date string.
 @result A RFC1123 date string.
 */
-(NSString*)rfc1123StringFromDate;


@end
