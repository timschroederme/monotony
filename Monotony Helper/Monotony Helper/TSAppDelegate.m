//
//  TSAppDelegate.m
//  Monotony Helper
//
//  Created by Tim Schröder on 03.06.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSAppDelegate.h"

@implementation TSAppDelegate

#define mainAppBundleIdentifier @"com.timschroeder.Monotony"
#define mainAppTrialBundleIdentifier @"com.timschroeder.Monotonytrial"
#define mainAppName @"Monotony"
#define terminateNotification @"TERMINATEHELPER"

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Prüfen, ob Hauptapp schon läuft
    BOOL alreadyRunning = NO;
    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running) {
        if ([[app bundleIdentifier] isEqualToString:mainAppBundleIdentifier]) {
            alreadyRunning = YES;
        }
        if ([[app bundleIdentifier] isEqualToString:mainAppTrialBundleIdentifier]) {
            alreadyRunning = YES;
        }
    }
    if (!alreadyRunning) {
        
        // Register Observer
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(killApp)
                                                                name:terminateNotification // Can be any string, but shouldn't be nil
                                                              object:mainAppBundleIdentifier];

        // Launch Main App
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSArray *p = [path pathComponents];
        NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:p];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents addObject:@"MacOS"];
        [pathComponents addObject:mainAppName];
        NSString *newPath = [NSString pathWithComponents:pathComponents];
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[NSURL fileURLWithPath:newPath]
                                                      options:NSWorkspaceLaunchWithoutActivation
                                                configuration:nil 
                                                        error:nil];
    } else {
        // Main App is already running, meaning that the helper was launched via SMLoginItemSetEnabled, kill the helper
        [self killApp];
    }
}

-(void)killApp
{
    [NSApp terminate:nil];
}

@end
