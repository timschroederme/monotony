//
//  TSAppDelegate.m
//  Monotony
//
//  Created by Tim Schröder on 31.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSAppDelegate.h"
#import "TSAppDelegate+Beta.h"
#import "TSAppDelegate+Trial.h"
#import "NSURL+Extensions.h"
#import "TSNotificationController.h"
#import "TSMainViewController.h"

@implementation TSAppDelegate

#define helperAppBundleIdentifier @"com.timschroeder.Monotony-Helper" // needed for launch at login detection
#define terminateNotification @"TERMINATEHELPER"

@synthesize window, launchURL, launching, notificationActivated, mainViewController;


#pragma mark -
#pragma mark NSApp Delegate

- (void) applicationWillFinishLaunching:(NSNotification*)aNotification
{
    // Launch Flag setzen
    self.launching = YES;
    
    // Register for URL Handling
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void) applicationDidFinishLaunching:(NSNotification*)aNotification
{
    // Launch Flag löschen
    self.launching = NO;
    
    // NotificationActivated Flag initialisieren
    self.notificationActivated = NO;
    
#ifdef BETA
    [self doBetaStuff];
#endif
    
#ifdef TRIAL
    [self doTrialStuff];
#endif
    
    // Init Notification Delegates
    [[TSNotificationController sharedController] initDelegates];
    [[TSNotificationController sharedController] setDelegate:self];
    
    // Feeds laden
    [self.mainViewController loadFeeds];
    
    // Hauptfenster anzeigen, wenn App nicht bei Login gestartet wurde
    BOOL startedAtLogin = NO;
    
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in apps) {
        if ([app.bundleIdentifier isEqualToString:helperAppBundleIdentifier]) startedAtLogin = YES;
    }
    
    if (startedAtLogin) {
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:terminateNotification
                                                                       object:[[NSBundle mainBundle] bundleIdentifier]];
    } else {
        [self.mainViewController showWindow];
    }
    
    // Subscription Window anzeigen, wenn App durch Url Handler gestartet wurde (s. die Callback-Methode)
    if (self.launchURL) [self.mainViewController showSubscriptionWindowWithURL:self.launchURL];
}

// Hauptfenster anzeigen, wenn App aktiviert wird
- (void) applicationDidBecomeActive:(NSNotification*)aNotification
{
    if (!self.notificationActivated) {
        [NSApp activateIgnoringOtherApps:YES];
        [self.mainViewController showWindow];
    }
    self.notificationActivated = NO;
}


#pragma mark -
#pragma mark NSAppleEventManager Callback Method

// Callback des Event-Handlers, der in App-Initialisierung gesetzt wurde
- (void) handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    // prefix monotony: löschen
     NSString* urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    if ([urlString hasPrefix:@"monotony://"]) {
        if ([urlString length]>11) urlString = [urlString substringFromIndex:11];
    }
    if ([urlString hasPrefix:@"monotony:"]) {
        if ([urlString length]>9) urlString = [urlString substringFromIndex:9];
    }
     NSURL *URL = [NSURL URLWithString:urlString];
    if (URL) {
        
        if (self.launching) {
            self.launchURL = URL;
        } else {
            [self.mainViewController showSubscriptionWindowWithURL:URL];
        }
    }
}


#pragma mark -
#pragma mark TSNotificationArrivedProtocol

-(void)notificationArrived
{
    self.notificationActivated = YES;
}


@end
