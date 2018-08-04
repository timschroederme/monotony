//
//  TSNotificationController.h
//  Monotony
//
//  Created by Tim Schröder on 26.12.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Growl/Growl.h"

@interface TSNotificationController : NSObject <GrowlApplicationBridgeDelegate, NSUserNotificationCenterDelegate>

+ (TSNotificationController *) sharedController;
-(void)initDelegates;

/** @name NSUserNotificationCenter Delegate Methods */

/** This delegate method is called by Mountain Lion's Notification Center and asks whether a notification sent by the application should really be presented. The method always returns yes.
 @param center not important.
 @param notification The notification to be presented.
 */
- (BOOL) userNotificationCenter:(NSUserNotificationCenter*)center shouldPresentNotification:(NSUserNotification*)notification;

/** This delegate method is called by Mountain Lion's Notification Center if the user has clicked on a notification. The implementation extracts the URL from the notification, opens it in the user's default web browser and removes the notification from the Notification Center.
 @param center not important.
 @param notification the notification the user activated.
 */
- (void) userNotificationCenter:(NSUserNotificationCenter*)center didActivateNotification:(NSUserNotification*)notification;


/** @name Growl Delegate Methods */

/** This delegate method is called by the Growl Framework to ask whether the delegate has sandbox entitlements.
 @return return value is always yes.
 */
- (BOOL) hasNetworkClientEntitlement;

/** This delegate method is called by the Growl Framework when the user has clicked on a notification. The implementation extracts the URL from the notification and opens it in the user's default web browser.
 @param clickContext a string containing the URL associated with the notification
 */
- (void) growlNotificationWasClicked:(id)clickContext;

-(void)displayNotificationWithTitle:(NSString*)caption
                           subTitle:(NSString*)subTitle
                            summary:(NSString*)summary
                          URLString:(NSString*)linkURLString
                              image:(NSImage*)image;

@property (assign) id delegate;

@end
