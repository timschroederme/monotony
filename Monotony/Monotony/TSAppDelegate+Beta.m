//
//  TSAppDelegate+Beta.m
//  Monotony
//
//  Created by Tim Schröder on 26.07.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSAppDelegate+Beta.h"

@implementation TSAppDelegate (Beta)


#define BETA_EXPIRY_DATE @"2013-04-30 00:00:00 +0000" // Date the beta will expire, format like "2012-12-15 00:00:00 +0000"


#pragma mark -
#pragma mark Public Methods

-(void)doBetaStuff
{
    if ([self checkIfBetaIsExpired]) {
        [self showBetaExpiredMessage]; // expired
        exit(0); // Terminate app
    } else {
        [self showRemainingBetaMessage]; // not expired
    }
}


#pragma mark -
#pragma mark Private Methods

// Compose info string about which beta version this is
-(NSString*)betaVersionTitle
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *buildVersion = [infoDict valueForKey:@"CFBundleShortVersionString"];
    NSString *buildNo = [infoDict valueForKey:@"CFBundleVersion"];
    NSString *buildName = [infoDict valueForKey:@"CFBundleName"];
    NSString *buildInfo = [NSString stringWithFormat:@"%@ %@ Beta", buildName, buildVersion];
    NSString *title = [NSString stringWithFormat:@"This is a %@ build (%@)", buildInfo, buildNo];
    return (title);
}

// Check if beta period has expired or not
-(BOOL)checkIfBetaIsExpired
{
    BOOL expired = NO;
    NSDate *expiryDate = [NSDate dateWithString:BETA_EXPIRY_DATE];
    NSDate *nowDate = [NSDate date];
    if ([expiryDate compare:nowDate] == NSOrderedAscending) expired = YES;
    return (expired);
}

// Beta is expired, show info about this
-(void)showBetaExpiredMessage
{
    // Get App Info & Compose Message to be shown
    NSAlert *alert = [NSAlert alertWithMessageText:[self betaVersionTitle]
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"Sorry, this beta build has expired. Please contact the developer."];
    
    // Show Message
    [alert runModal];
}

// Beta period still running, show message
-(void)showRemainingBetaMessage
{
    // Compose display string of expiry date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    NSDate *expiryDate = [NSDate dateWithString:BETA_EXPIRY_DATE];

    // Show Message
    NSAlert *alert = [NSAlert alertWithMessageText:[self betaVersionTitle]
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"This beta build will expire on %@", [dateFormatter stringFromDate:expiryDate]];
    [alert runModal];
}


@end
