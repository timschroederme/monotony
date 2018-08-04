//
//  TSAppDelegate+Trial.m
//  Monotony
//
//  Created by Tim Schröder on 22.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSAppDelegate+Trial.h"


// Constant Values

#define TRIAL_FACTOR 1000 // fake factor to calculate trial period storage

#define APPSTORE_NAME @"Monotony"
#define APPSTORE_URL @"http://itunes.apple.com/us/app/monotony/id533978766?mt=12"
#define DEFAULTS_TRIALINTERVAL @"Runtime Version" // fake key to store trial period
#define DEFAULTS_VERSION @"Bundle Version"
#define TRIAL_MESSAGE @"This trial version of %@ may be used for %i more days."
#define TRIAL_DIALOG_CAPTION @"Thanks for using %@!"
#define TRIAL_LAUNCH_BUTTON @"Buy %@"
#define TRIAL_OK_BUTTON @"OK"
#define TRIAL_EXPIRED_MESSAGE @"To continue using %@ please purchase a license."
#define TRIAL_CLOSE_BUTTON @"Quit"
#define TRIAL_EXPIRED_CAPTION @"This trial version of %@ has expired"
#define TRIAL_PERIOD 30 // trial period in days


@implementation TSAppDelegate (Trial)


#pragma mark -
#pragma mark Public Methods

// Einzige öffentliche Methode, wird von AppDelegate aufgerufen
-(void)doTrialStuff
{
    if ([self checkIfTrialIsExpired]) {
        [self showTrialExpiredMessage]; // expired
    } else {
        [self showRemainingTrialMessage]; // not expired
    }
}


#pragma mark -
#pragma mark Private Methods

// Registriert Trial-Daten in UserDefaults
-(void)registerTrialData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval registerInterval = [[NSDate date] timeIntervalSince1970];
    [defaults setInteger:(int)(registerInterval/TRIAL_FACTOR) forKey:DEFAULTS_TRIALINTERVAL];
    
    NSString *temp = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    NSInteger bundleVersion = [temp integerValue];
    [defaults setInteger:bundleVersion forKey:DEFAULTS_VERSION];
    [defaults synchronize];
}

// Check if trial period has expired or not
-(BOOL)checkIfTrialIsExpired
{
    BOOL expired = NO;
    
    // Versionskontrolle (Trial fängt bei neuer Version neu an zu laufen)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger defaultsVersion = [defaults integerForKey:DEFAULTS_VERSION];
    NSString *temp = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    NSInteger bundleVersion = [temp integerValue];
    
    if (bundleVersion > defaultsVersion) {
        // Trial zurücksetzen
        [self registerTrialData];
    } else {
        if ([self remainingTrialPeriod] == 0) expired = YES;
    }
    
    return expired;
}

// Calculate remaining trial period
-(int)remainingTrialPeriod
{
    int daysRemaining;
 	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSTimeInterval defaultsInterval = (double)[defaults integerForKey:DEFAULTS_TRIALINTERVAL]*TRIAL_FACTOR;
    if (defaultsInterval!=0) {
        // trial key already present in preferences, calculate remaining trial period
        NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
        double diff = nowInterval - defaultsInterval;
        double rest = (60*60*24*TRIAL_PERIOD)-diff;
        if (diff > (60*60*24*TRIAL_PERIOD)) {
            daysRemaining = 0;
        } else {
            daysRemaining = (int)(rest/(60*60*24));
            daysRemaining++;
        }
    } else {
        // trial key not present in preferences, register it with present date
        [self registerTrialData];
        daysRemaining = TRIAL_PERIOD;
    }
    return daysRemaining;
}

// Show message window that trial period has expired, then quit the application
-(void)showTrialExpiredMessage
{
    NSString *caption = [NSString stringWithFormat:TRIAL_EXPIRED_CAPTION, APPSTORE_NAME];
    NSString *launch = [NSString stringWithFormat:TRIAL_LAUNCH_BUTTON, APPSTORE_NAME];
    NSInteger result = [[NSAlert alertWithMessageText:caption
                                        defaultButton:TRIAL_CLOSE_BUTTON
                                      alternateButton:launch
                                          otherButton:nil
                            informativeTextWithFormat:TRIAL_EXPIRED_MESSAGE, APPSTORE_NAME] runModal];
    if (result == NSAlertAlternateReturn) [self openAppStore];
    exit(0);
}

// Show message window with info on remaining trial period
-(void)showRemainingTrialMessage
{
    NSString *caption = [NSString stringWithFormat:TRIAL_DIALOG_CAPTION, APPSTORE_NAME];
    NSString *launch = [NSString stringWithFormat:TRIAL_LAUNCH_BUTTON, APPSTORE_NAME];
    NSInteger result = [[NSAlert alertWithMessageText:caption
                                        defaultButton:TRIAL_OK_BUTTON
                                      alternateButton:launch
                                          otherButton:nil
                            informativeTextWithFormat:TRIAL_MESSAGE, APPSTORE_NAME, [self remainingTrialPeriod]] runModal];
    if (result == NSAlertAlternateReturn) [self openAppStore];
}

// Launch Mac App Store to show application
-(void)openAppStore
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:APPSTORE_URL]];
}


@end
