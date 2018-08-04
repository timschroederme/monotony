//
//  TSLaunchAtLoginController.m
//  Brow
//
//  Created by Tim Schröder on 13.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSLaunchAtLoginController.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation TSLaunchAtLoginController

#define helperAppBundleIdentifier @"com.timschroeder.Monotony-Helper"

static TSLaunchAtLoginController *_sharedController = nil;

#pragma mark -
#pragma mark Singleton Methods

+ (TSLaunchAtLoginController *)sharedController
{
	if (!_sharedController) {
        _sharedController = [[super allocWithZone:NULL] init];
    }
    return _sharedController;
}	

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedController];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


#pragma mark -
#pragma mark Status Item Action Methods

-(void)turnOnLaunchAtLogin
{
    if (!SMLoginItemSetEnabled ((__bridge CFStringRef)helperAppBundleIdentifier, YES)) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Couldn't add Monotony to the launch-at-login item list."];
        [alert runModal];
    }
}

-(void)turnOffLaunchAtLogin
{
    if (!SMLoginItemSetEnabled ((__bridge CFStringRef)helperAppBundleIdentifier, NO)) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Couldn't remove Monotony from the launch-at-login item list."];
        [alert runModal];
    }
}


@end
