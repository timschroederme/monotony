//
//  NSData+Extensions.h
//  Monotony
//
//  Created by Tim Schröder on 15.11.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Extensions)

/** Converts the receiver into a base64 string.
 @result The converted base64 string.
 */
-(NSString *)encode;


@end
