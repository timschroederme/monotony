//
//  TSStatusItemController.m
//  Brow
//
//  Created by Tim Schröder on 11.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSStatusItemController.h"
#import "TSImageView.h"

@implementation TSStatusItemController

@synthesize statusItem, action, target;

static TSStatusItemController *_sharedController = nil;

#pragma mark -
#pragma mark Singleton Methods

+ (TSStatusItemController *)sharedController
{
	if (!_sharedController) {
        _sharedController = [[super allocWithZone:NULL] init];
    }
    return _sharedController;
}	

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedController];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


#pragma mark -
#pragma mark Status Item Action Methods

-(void)showStatusIcon
{
    if (!statusItem) {
        statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        
        NSImage *image = [NSImage imageNamed:@"menuicon"]; // do not have ".png" here, or Retina won't work
        
        // Check if running on OS X 10.10 or on OS X 10.9
        if ([statusItem respondsToSelector:NSSelectorFromString(@"button")]) // @button property is new in OS X 10.10
        {
            // New Yosemite Code
            [image setTemplate:true]; // NSImage template will only work when image is within a NSButton
             NSStatusBarButton *button = [statusItem button];
             button.image = image;
             button.action = [self action];
             button.target = [self target];
        } else {
            // Old pre Yosemite Code
            TSImageView *statusView = [[TSImageView alloc] init];
            [statusView setImage:image];
            [statusView setAction:[self action]];
            [statusView setTarget:[self target]];
            [statusItem setView:statusView];
        }
    }
}

-(void)hideStatusIcon
{
    if (!statusItem) return;
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
    statusItem = nil;
}

@end
