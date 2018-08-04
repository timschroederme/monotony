//
//  TSLaunchAtLoginController.h
//  Brow
//
//  Created by Tim Schröder on 13.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The TSLaunchAtLoginController class enables and disables launching the app at login. As during login the main app cannot be launched directly, but only with the diversion of a helper app, the main app needs such an external helper app, whose bundle identifier it needs to know. 
 
 @discussion At the moment, the bundle identifier of the helper app is hard-wired in the implementation of TSLaunchAtLoginController and set to 'com.timschroeder.Monotony-Helper'.
 */

@interface TSLaunchAtLoginController : NSObject

/** Returns the singleton instance of the class.
 @return The shared instance.
 */
+ (TSLaunchAtLoginController *) sharedController;

/** Turns on launching the app at login. If something goes wrong, the method displays an alert to the user.
 */
- (void) turnOnLaunchAtLogin;

/** Turns off launching the app at login. If something goes wrong, the method displays an alert to the user.
 */
- (void) turnOffLaunchAtLogin;


@end
