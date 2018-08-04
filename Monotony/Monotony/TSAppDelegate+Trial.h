//
//  TSAppDelegate+Trial.h
//  Monotony
//
//  Created by Tim Schröder on 22.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//


#import "TSAppDelegate.h"

@interface TSAppDelegate (Trial)

/** If the build configuration is set to build the trial version, this method is called by the app delegate. It checks if the encrypted expiration date set in the user defaults has already arrived. If this is the case, the method will terminate the app. Otherwise, it will present an information about when the trial version will expire. 
 */
-(void)doTrialStuff;

/** Stores the encrypted date of the first launch in the user defaults of the app. Is called by -checkIfTrialIsExpired and -remainingTrialPeriod. Private method, shouldn't be called directly.
 @warning This method doesn't use the TSDefaultsController singleton.
 */
-(void)registerTrialData;

/** This method checks if the trial period is still running. It also resets the trial period if the bundle version of the app has changed. Private method, shouldn't be called directly.
 @return Returns YES if the trial period is expired, NO if this is not the case.
 */
-(BOOL)checkIfTrialIsExpired;

/** This methods calculated the remaining trial period by reading out the date the trial was first launched from the app's user defaults. If the trial version build is launched for the first time, the method stores the encrypted date of the first launch in the user defaults of the app. Private method, shouldn't be called directly.
 
 @discussion The method uses the TRIAL_PERIOD constant to calculate the remaining trial period. The method is called by the -checkIfTrialIsExpired method.
 @warning This method doesn't use the TSDefaultsController singleton.
 @return Remaining trial period (in days). If the trial period is expired, the method returns 0.
 */
-(int)remainingTrialPeriod;

/** Displays an alert showing that the trial period is expired. Private method, shouldn't be called directly.
 */
-(void)showTrialExpiredMessage;

/** Displays an alert showing the remaining trial period. Private method, shouldn't be called directly.
 */
-(void)showRemainingTrialMessage;

/** Opens the Mac App Store to show the product page of Monotony. Uses the APPSTORE_URL constant. Private method, shouldn't be called directly.
 */
-(void)openAppStore;

@end
