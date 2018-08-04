//
//  TSImageView.m
//  Brow
//
//  Created by Tim Schröder on 06.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSImageView.h"
#import "TSAppDelegate.h"

@implementation TSImageView

@synthesize action, target;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mouseMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSMouseMovedMask|NSLeftMouseDownMask handler:^(NSEvent *event) {
            if (([event type] == NSLeftMouseDown) && ([[event window] isEqualTo:[self window]])) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if ([target respondsToSelector:action]) {
                    [target performSelector:action];
                }
#pragma clang diagnostic pop
            }
            return event;
        }];
    }
    return self;
}

@end
