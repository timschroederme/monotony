//
//  NSString+Extensions.h
//  Monotony
//
//  Created by Tim Schröder on 07.02.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

/** NSString category for better html-encoded string handling.
 */

@interface NSString (Extensions)

/** This methods returns a copy of the receiver with decoded HTML entities.
 @return A new NSString instance containing the decoded string.
 */
-(NSString *) stringByStrippingHTML;


@end
