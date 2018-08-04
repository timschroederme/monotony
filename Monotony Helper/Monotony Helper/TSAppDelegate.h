//
//  TSAppDelegate.h
//  Monotony Helper
//
//  Created by Tim Schröder on 03.06.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** The (sandboxed) helper app for Monotony consists just out of the TSAppDelegate class. The only purpose of the helper app is to launch the main application. The helper app is launched by the OS at login if the user has enabled this behaviour. It is identified by the OS by its bundle identifier string, i.e. *com.timschroeder.Monotony-Helper*.
 
 @discussion After it is launched, the helper app checks if the main app is already running (using the hard-wired *mainAppBundleIdentifier* and *mainAppTrialBundleIdentifier* strings). If the main app is already running, the helper app does nothing and just terminates. If the main app isn't already running, the helper app launches it from inside the joint application bundle and passes on a specific hard-wired *launchArgument* in order to enable the main app to determine whether it has been launched during login or not. After the main application has been launched, the helper app is terminated.
 
 The helper app doesn't need to have a main window and its *Application is background only* attribute should be set to *YES* in order to the helper app doesn't become visible during its operations.
 
 @warning The helper app will only be called by the OS during login if the application bundle is stored inside the /Applications or the ~/Applications folder. The main app needs to incorporate the helper app's build product in a specific way as described in http://blog.timschroeder.net/2012/07/03/the-launch-at-login-sandbox-project/.
 */

@interface TSAppDelegate : NSObject <NSApplicationDelegate>

@end
