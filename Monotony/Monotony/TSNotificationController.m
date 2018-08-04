//
//  TSNotificationController.m
//  Monotony
//
//  Created by Tim Schröder on 26.12.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSNotificationController.h"
#import "TSDefaultsController.h"
#import "TSNotificationArrivedProtocol.h"

@implementation TSNotificationController

@synthesize delegate;

static TSNotificationController *_sharedController = nil;

#pragma mark -
#pragma mark Singleton Methods

+ (TSNotificationController *)sharedController
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
#pragma Initialization Method

-(void)initDelegates
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self]; // Init Notification Center
    [GrowlApplicationBridge setGrowlDelegate:self]; // Init Growl
}


#pragma mark -
#pragma mark Check Methods

// Returns YES if Growl should be used to display notifications, otherwise NO
-(BOOL)useGrowl
{
    BOOL useGrowl = YES;
    if ([NSUserNotificationCenter class]) {
        useGrowl = NO;
        if ([[TSDefaultsController sharedController] useGrowl]) useGrowl = YES;
    }
    return useGrowl;
}


#pragma mark -
#pragma mark Open URL Method

-(void)openURL:(NSURL*)URL
{
    if (URL) [[NSWorkspace sharedWorkspace] openURL:URL];
}


#pragma mark -
#pragma mark NSUserNotificationCenter Delegate Methods

- (BOOL) userNotificationCenter:(NSUserNotificationCenter*)center shouldPresentNotification:(NSUserNotification*)notification
{
    return YES;
}

- (void) userNotificationCenter:(NSUserNotificationCenter*)center didActivateNotification:(NSUserNotification*)notification
{
    if (self.delegate && [delegate conformsToProtocol:@protocol(TSNotificationArrivedProtocol)] && [delegate respondsToSelector:@selector(notificationArrived)]) {
        [delegate notificationArrived];
    }

    NSString *URLString = [[notification userInfo] valueForKey:@"clickcontext"];
    [self openURL:[NSURL URLWithString:URLString]];
    [center removeDeliveredNotification:notification];
}


#pragma mark -
#pragma mark Growl Delegate Methods

- (BOOL) hasNetworkClientEntitlement
{
    return YES;
}

- (void) growlNotificationWasClicked:(id)clickContext
{
    NSString *URLString = [clickContext stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self openURL:[NSURL URLWithString:URLString]];
}


#pragma mark -
#pragma mark Notification Display Methods

-(void)displayNotificationWithTitle:(NSString*)caption
                           subTitle:(NSString*)subTitle
                            summary:(NSString*)summary
                          URLString:(NSString*)linkURLString
                              image:(NSImage*)image
{
    if ([self useGrowl]) {
        // Use Growl
        [GrowlApplicationBridge notifyWithTitle:caption
                                    description:summary
                               notificationName:@"News" // stattdessen feed.title nehmen? 
                                       iconData:[image TIFFRepresentation]
                                       priority:0
                                       isSticky:NO
                                   clickContext:linkURLString];
    } else {
        // Use NotificationCenter
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:caption];
        [notification setSubtitle:subTitle];
        [notification setInformativeText:summary];
        [notification setSoundName:NSUserNotificationDefaultSoundName];
        if (linkURLString == nil) [notification setHasActionButton:NO];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:linkURLString, @"clickcontext", nil];
        [notification setUserInfo:userInfo];
        
        // New and only working on OS X 10.9
        //[notification setContentImage:image];
        
        // Present Notification
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
}


@end
