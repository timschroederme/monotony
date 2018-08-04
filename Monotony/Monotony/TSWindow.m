//
//  TSWindow.m
//  Brow
//
//  Created by Tim Schröder on 14.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSWindow.h"

@implementation TSWindow

// Controls Escape key behaviour
- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent keyCode] == 53) {
        [self close];
    } else {
        [super keyDown:theEvent];
    }
}


@end
