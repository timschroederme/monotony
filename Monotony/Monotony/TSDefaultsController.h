//
//  TSDefaultsController.h
//  Brow
//
//  Created by Tim Schröder on 11.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The purpose of this singleton class is to channel and maintain all operations with regard to the app's user defaults. To achieve this, the class presents getter and setter methods for all settings to the stored in the app's user defaults.
 */

@interface TSDefaultsController : NSObject

/** @name Communicating with the Class */

/** Returns the singleton instance of the class.
 @return The shared instance.
 */
+ (TSDefaultsController *) sharedController;

/** @name Running Visible or Invisible */

/** Stores the setting for running invisible or visible in the app's user defaults.
 @param flag Should be YES if the app is going to run invisible, NO if the app should be visible in the status bar.
 */
-(void)setRunInvisible:(BOOL)flag;

/** Returns the current setting with regard to running invisible.
 @return The method returns YES if the stored setting is to run invisible, NO if the stored setting is to run visible.
 */
-(BOOL)runInvisible;

/** @name Launch at Login */

/** Stores the setting for launching at login or not in the app's user defaults.
 @param flag Should be YES if the app is to be launched at login, NO if the app shouldn't be launched at login.
 */
-(void)setLaunchAtLogin:(BOOL)flag;

/** Returns the current setting with regard to launching at login.
 @return The method returns YES if the stored setting is to launch at login, NO if the stored setting is to not launch at login.
 */
-(BOOL)launchAtLogin;


/** @name Use Growl */

/** Stores the setting for using Growl on OS X 10.8 
 @param flag Should be YES if the app should use Growl, NO if the app should use the Notification Center.
 */
-(void)setUseGrowl:(BOOL)flag;

/** Returns the current setting with regard to using Growl.
 @return The method returns YES if the stored setting is to use Growl, NO if the stored setting is to not use Growl.
 */
-(BOOL)useGrowl;

@end
