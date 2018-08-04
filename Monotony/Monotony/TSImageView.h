//
//  TSImageView.h
//  Brow
//
//  Created by Tim Schröder on 06.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSAppDelegate;

@interface TSImageView : NSImageView
{
    id mouseMonitor;
}

@property (assign) SEL action;
@property (assign) id target;

@end
