//
//  TSSubscriptionController.m
//  Monotony
//
//  Created by Tim Schröder on 17.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSSubscriptionController.h"
#import "TSSubscriptionViewController.h"
#import "NSString+Extensions.h"
#import "NSData+Extensions.h"
#import "NSURL+Extensions.h"
#import "TSFeedController.h"
#import "TSSubscription.h"
#import "TSSubscriptionProtocol.h"


@implementation TSSubscriptionController

#pragma mark -
#pragma mark Public Methods

// Wird von MainController aufgerufen
-(void) showSubscriptionWindowWithURL:(NSURL*)URL
{
    [self.subscriptionViewController showSubscriptionWindowWithURL:URL];
}

// Wird von SubscriptionViewController aufgerufen, wenn User URL eingegeben oder ausgewählt hat
-(void) startSubscriptionWithURL:(NSURL*)URL
{
    self.subscription = [[TSSubscription alloc] init];
    [self.subscription setDelegate:self];
    [self.subscription startSubscriptionWithURL:URL];
}

// Wird von MainViewController beim Importieren von Feeds aufgerufen
- (void) importURLs:(NSArray*)urlArray
{
    if ((!urlArray) || ([urlArray count]==0)) return;
    
    // UI vorbereiten
    [self.subscriptionViewController showBusyView];
    
    // Import vorbereiten
    self.importing = YES;
    self.importSuccessCount = 0;
    self.importCount = [urlArray count];
    self.importIdx = 0;
    if (self.importQueue) {
        [self.importQueue removeAllObjects];
    } else {
        self.importQueue = [NSMutableArray arrayWithCapacity:0];
    }
    [self.importQueue addObjectsFromArray:urlArray];
    [self startSubscriptionWithURL:[self.importQueue objectAtIndex:0]];
    self.importIdx++;
    [self.subscriptionViewController setCustomSubscribingCaption:@"Importing.."];
    [self.importQueue removeObjectAtIndex:0];
}


// Wird von SubscriptionViewController aufgerufen, wenn User Subscription abbricht
-(void) cancelSubscription
{
    [self.subscription cancelSubscription];
    self.importing = NO;
}

/*
 -(void)wrongCredentialsForFeed:(TSFeed*) feed
 {
 TSKeychainItem *keychainItem = [feed keychainItemWithoutPath];
 if (keychainItem) {
 [keychainItem deleteItem];
 } else {
 NSLog (@"Error while trying to remove keychain entry");
 }
 [self.subscriptionViewController wrongCredentials];
 }
 
 -(void) enteredCredentialsWithURL:(NSURL*)URL username:(NSString*)username password:(NSString*)password;
 {
    [self.pubSubController subscribeToProtectedFeedWithURL:URL username:username password:password];
 }
 
 */


#pragma mark -
#pragma mark Import Helper Methods

-(void)importNextFeedInQueue
{
    if ([self.importQueue count]>0) {
        self.importIdx++;
        NSString *caption = [NSString stringWithFormat:@"Importing Feed %li of %li..", self.importIdx, self.importCount];
        [self.subscriptionViewController setCustomSubscribingCaption:caption];
        [self startSubscriptionWithURL:[self.importQueue objectAtIndex:0]];
        [self.importQueue removeObjectAtIndex:0];
    }
}


#pragma mark -
#pragma mark TSSubscriptionProtocol Delegate

-(void) askForCredentials
{
    [self.subscriptionViewController askForCredentials];
}

-(void) subscriptionFailedWithError:(NSError*)error
{
    if (!self.importing) {
        [self.subscriptionViewController showErrorMessage:error];
    } else {
        [self importNextFeedInQueue];
    }
}

-(void) chooseFromFeeds:(NSArray*)feeds
{
    [self.subscriptionViewController showMultipleFeedsForSelection:feeds];
}

-(void) subscriptionSucceededWithURL:(NSURL*)feedURL
                                icon:(NSImage*)feedIcon
                               title:(NSString*)feedTitle
{
    BOOL alreadySubscribed = [self.feedController alreadySubscribedToFeedURL:feedURL];

    if (!self.importing) {
        [self.subscriptionViewController cancelSubscription:self]; // UI ändern

        // Prüfen, ob Feed bereits abonniert ist
        if (alreadySubscribed) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"You're already subscribed to this feed." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You can't subscribe to the same feed twice."];
            [alert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
            return;
        } else {
            [self.feedController addFeedWithURL:feedURL
                                           icon:feedIcon
                                          title:feedTitle
                                       username:@""
                               showNotification:YES];
        }
    } else {
        if (!alreadySubscribed) {
            [self.feedController addFeedWithURL:feedURL
                                           icon:feedIcon
                                          title:feedTitle
                                       username:@""
                               showNotification:NO];
            self.importSuccessCount++;
        }
        // Nächsten Feed importieren
        if ([self.importQueue count]>0) {
            [self importNextFeedInQueue];
        } else {
            self.importing = NO;
            [self.subscriptionViewController showImportSuccessInfo:self.importSuccessCount];
        }
    }
}


@end
