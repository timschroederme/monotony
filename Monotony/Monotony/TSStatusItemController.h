//
//  TSStatusItemController.h
//  Brow
//
//  Created by Tim Schröder on 11.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */

@interface TSStatusItemController : NSObject

/** 
 */
+ (TSStatusItemController *) sharedController;

/** 
 */
- (void) showStatusIcon;

/**
 */
- (void) hideStatusIcon;

/**
 */
@property (strong) NSStatusItem *statusItem;

/**
 */
@property (assign) SEL action;

/**
 */
@property (assign) id target;

@end
