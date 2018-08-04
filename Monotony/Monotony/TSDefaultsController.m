//
//  TSDefaultsController.m
//  Brow
//
//  Created by Tim Schröder on 11.05.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSDefaultsController.h"

#define DEFAULTS_RUNINVISIBLE @"RunInvisible"
#define DEFAULTS_LAUNCHATLOGIN @"LaunchAtLogin"
#define DEFAULTS_USEGROWL @"UseGrowl"

@implementation TSDefaultsController

static TSDefaultsController *_sharedController = nil;

#pragma mark -
#pragma mark Singleton Methods

+ (TSDefaultsController *)sharedController
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
#pragma mark Other Defaults Methods

-(void)setRunInvisible:(BOOL)flag
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [NSNumber numberWithBool:flag];
    [defaults setObject:num forKey:DEFAULTS_RUNINVISIBLE];
    [defaults synchronize];
}

-(BOOL)runInvisible
{
    BOOL result = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [defaults objectForKey:DEFAULTS_RUNINVISIBLE];
    if (num) result = [num boolValue];
    return (result);
}

-(void)setLaunchAtLogin:(BOOL)flag
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [NSNumber numberWithBool:flag];
    [defaults setObject:num forKey:DEFAULTS_LAUNCHATLOGIN];
    [defaults synchronize];
}

-(BOOL)launchAtLogin
{
    BOOL result = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [defaults objectForKey:DEFAULTS_LAUNCHATLOGIN];
    if (num) result = [num boolValue];
    return (result);
}

-(void)setUseGrowl:(BOOL)flag
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [NSNumber numberWithBool:flag];
    [defaults setObject:num forKey:DEFAULTS_USEGROWL];
    [defaults synchronize];
}

-(BOOL)useGrowl
{
    BOOL result = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [defaults objectForKey:DEFAULTS_USEGROWL];
    if (num) result = [num boolValue];
    return (result);
}

@end
