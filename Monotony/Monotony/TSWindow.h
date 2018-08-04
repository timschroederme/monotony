//
//  TSWindow.h
//  Brow
//
//  Created by Tim Schröder on 14.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** This NSWindow subclass alters the behaviour of the window: Pressing the Escape key when the window is visible closes the window.
 */

@interface TSWindow : NSWindow

/** Overriden method: If the Escape key is pressed, the window is closed.
 @param theEvent not important.
 */
- (void)keyDown:(NSEvent *)theEvent;

@end
