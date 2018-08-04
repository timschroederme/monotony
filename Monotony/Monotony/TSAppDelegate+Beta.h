//
//  TSAppDelegate+Beta.h
//  Monotony
//
//  Created by Tim Schröder on 26.07.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//


#import "TSAppDelegate.h"


@interface TSAppDelegate (Beta)

/**  If the build configuration is set to build the beta version, this method is called by the app delegate. It checks if the expiration date set in the implementation file of this category (BETA_EXPIRY_DATE) has already arrived. If this is the case, the method will terminate the app. Otherwise, it will present an information about when the beta version will expire. 
 
 @discussion  This method is the only method of this category that should needed to be called directly, preferably early in the app's -applicationDidFinishLaunching: method. It checks if the beta is expired, and if it is, displays an alert and terminates the app. If the beta isn't yet expired, it shows an alert containing the remaining beta period.
 
 @warning The BETA_EXPIRY_DATE has to be in this format: "2012-12-15 00:00:00 +0000". If the beta build is used, the main window will called even during a launch at login, as an alert will be shown in any case.
 */
-(void)doBetaStuff;

/** Composes the full name of the beta version in the format 'This is the %app name and version build (%build number)'. Private method, shouldn't be called directly.
 @return The composed string.
 */
-(NSString*)betaVersionTitle;

/** Compares the actual date with the expiry date of the beta. Private method, shouldn't be called directly. 
 @return Returns YES if the beta is expired, NO if it isn't.
 */
-(BOOL)checkIfBetaIsExpired;

/** Shows an alert informing the user that the beta period is expired. Private method, shouldn't be called directly. 
 */
-(void)showBetaExpiredMessage;

/** Shows an alert with the remaining beta period. Private method, shouldn't be called directly.
 */
-(void)showRemainingBetaMessage;

@end
