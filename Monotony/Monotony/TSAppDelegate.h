//
//  TSAppDelegate.h
//  Monotony
//
//  Created by Tim Schröder on 31.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TSNotificationArrivedProtocol.h"


/** This class takes care of some fundamental tasks.
 
 The main task of this class is to manage application startup and termination. In addition, it serves as delegate for the Notication Center (on OS X 10.8) and Growl (on OS X 10.7) and handles callbacks from the Monotony:// protocol.
  
*/

@class TSMainViewController;

@interface TSAppDelegate : NSObject <NSApplicationDelegate, TSNotificationArrivedProtocol>

/** @name NSApp Delegate */

/** Is called early during startup. The method installs the AppleEvent callback handler (as otherwise launching Monotony with an URL wouldn't work) and sets TSAppDelegate's launching property.
 @param aNotification not important.
 */
- (void) applicationWillFinishLaunching:(NSNotification*)aNotification;

/** Is called late during startup. The method clears TSAppDelegate's *launching* property, calls trial and/or beta methods (according to the build configuration) and establish delegations for the Notification Center or the Growl framework. If the application wasn't started during login, the method finally displays the main window.
 @param aNotification not important.
 */
- (void) applicationDidFinishLaunching:(NSNotification*)aNotification;

/** Is called when the aplication has become active and brings the main window to front. However, if the notificationActivated property is set to TRUE, the main window won't be shown.
 
 @warning If Monotony is running as a beta build, launching the app at login will always display the main window as the doBetaStuff method will show an information alert, which will cause the main window to be shown.
 @param aNotification not important.
 */
- (void) applicationDidBecomeActive:(NSNotification*)aNotification;


/** @name NSAppleEventManager Callback Method */

/** This callback method is called when an URL event occured, i.e. when the user activated a Monotony:// URL scheme. The method extracts the URL from the event and opens the subscription window.
 @param event not important.
 @param replyEvent not important.
 */
- (void) handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent;


/** Main window reference. */
@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet TSMainViewController *mainViewController;

/** launchURL reference. Used by the handleURLEVent callback method to pass on information about the URL to the applicationDidFinishLaunching: method (as the subscription window cannot be opened before the application has finished launching).  */
@property (strong) NSURL *launchURL;

/** This property is YES as long as the application is launching. It is needed by the handleURLEvent: method to determine what to do with the URL. */
@property (assign) BOOL launching;

/** This property will be set to YES by the TSNotificationController delegate method and is read by the applicationDidBecomeActive: method. 
 
 @discussion This property is used as a bug fix: If the user clicks on a notification in the Notification Center and the default web browser is not already running, Monotony will receive an applicationDidBecomeActive: notification, which will lead to its main window being displayed. This is to be avoided, so checking if this property is set inside the applicationDidBecomeActive: method is needed to not display the main window if the web browser isn't already running. The applicationDidBecomeActive: method clears the property after questioning it.
 */
@property (assign) BOOL notificationActivated;

@end
