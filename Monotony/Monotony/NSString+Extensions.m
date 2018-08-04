//
//  NSString+Extensions.m
//  Monotony
//
//  Created by Tim Schröder on 07.02.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

-(NSString *) stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    s = [s stringByReplacingOccurrencesOfString:@"&#38;" withString:@"&"];
    s = [s stringByReplacingOccurrencesOfString:@"&#160;" withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"&#8211;" withString:@"–"];
    s = [s stringByReplacingOccurrencesOfString:@"&#8217;" withString:@"'"];
    s = [s stringByReplacingOccurrencesOfString:@"&#8216;" withString:@"'"];
    s = [s stringByReplacingOccurrencesOfString:@"&#8220;" withString:@"\u201c"];
    s = [s stringByReplacingOccurrencesOfString:@"&#8221;" withString:@"\u201d"];
    s = [s stringByReplacingOccurrencesOfString:@"&#8212;" withString:@"\u2014"];
    s = [s stringByReplacingOccurrencesOfString:@"&#8734;" withString:@"\u221e"];
    
    s = [s stringByReplacingOccurrencesOfString:@"#38;" withString:@"&"];
    s = [s stringByReplacingOccurrencesOfString:@"#160;" withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"#8211;" withString:@"–"];
    s = [s stringByReplacingOccurrencesOfString:@"#8217;" withString:@"'"];
    s = [s stringByReplacingOccurrencesOfString:@"#8220;" withString:@"\u201c"];
    s = [s stringByReplacingOccurrencesOfString:@"#8221;" withString:@"\u201d"];
    s = [s stringByReplacingOccurrencesOfString:@"#8212;" withString:@"\u2014"];
    s = [s stringByReplacingOccurrencesOfString:@"#8734;" withString:@"\u221e"];
    
    s = [s stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    s = [s stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    s = [s stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    s = [s stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    s = [s stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    s = [s stringByReplacingOccurrencesOfString:@"    " withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"   " withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"¬" withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    
    s = [s stringByReplacingOccurrencesOfString:@"\n\r" withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%C", (unichar)NSParagraphSeparatorCharacter] withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%C", (unichar)NSLineSeparatorCharacter] withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"\\u002e" withString:@" "];
    return s;
}


@end
