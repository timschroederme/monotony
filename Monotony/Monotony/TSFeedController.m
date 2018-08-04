//
//  TSFeedController.m
//  Monotony
//
//  Created by Tim Schröder on 26.12.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSFeedController.h"
#import "TSFeed.h"
#import "NSWorkspace+Extensions.h"
#import "NSError+Log.h"
#import "TSMainViewController.h"
#import "NSURL+Extensions.h"

@implementation TSFeedController

@synthesize feedArrayController, refreshIndex, refreshTimer, mainViewController;


#pragma mark -
#pragma mark Feed Properties Access Methods

// Called by TSMainViewController
-(NSURL*)URLForTableRow:(NSInteger)row
{
    NSURL *result;
    TSFeed *aFeed = [[self.feedArrayController arrangedObjects] objectAtIndex:row];
    if (aFeed) result = aFeed.URL;
    return result;
}

// Called by TSMainViewController
-(NSInteger)selectionIndex
{
    return [self.feedArrayController selectionIndex];
}

// Called by TSMainViewController
-(void)saveSelectedFeedAndRearrange
{
    NSInteger selectionIndex = [self selectionIndex];
    if (selectionIndex == NSNotFound) return;
    [[[self.feedArrayController arrangedObjects] objectAtIndex:selectionIndex] saveFeed];
    [self.feedArrayController rearrangeObjects];
}

// Called by TSMainViewController for Feed URL Export
-(NSArray*)allFeeds
{
    return [self.feedArrayController arrangedObjects];
}

#pragma mark -
#pragma mark Feed Administration Methods

// Nimmt neuen Feed in Array auf, wird von -loadFeeds aufgerufen
-(void)addFeed:(TSFeed *)feed
{    
    // Feed zu Array hinzufügen, starten und speichern
    [self.feedArrayController addObject:feed];
    [self.feedArrayController rearrangeObjects];
}

-(void) addFeedWithURL:(NSURL*)feedURL
                  icon:(NSImage*)icon
                 title:(NSString*)title
              username:(NSString*)username
      showNotification:(BOOL)showNotification
{
    // Feed erzeugen
    TSFeed *feed = [[TSFeed alloc] init];
    feed.URL = feedURL;
    feed.originalIcon = icon;
    feed.title = title;
    feed.username = username;
    
    // Feed zu Array hinzufügen, starten und speichern
    [self.feedArrayController addObject:feed];
    [feed startOperationsWithNotification:showNotification];
    [feed saveFeed]; // Wichtig, falls Feed gleich wieder gelöscht wird
    
    [self.feedArrayController setSelectedObjects:[NSArray arrayWithObject:feed]];
    NSInteger idx = [self.feedArrayController selectionIndex];
    if (idx == NSNotFound) return;
    [self.feedArrayController rearrangeObjects];
    [self.mainViewController scrollTableToRow:[self.feedArrayController selectionIndex]];
    [self adjustRefreshTimer];
}


-(void)unsubscribeFromSelectedFeed
{
    NSInteger idx = [self.feedArrayController selectionIndex];
    if (idx == NSNotFound) return;
    TSFeed *feed = [[self.feedArrayController arrangedObjects] objectAtIndex:idx];
    [self.feedArrayController removeObject:feed];
    [feed deleteFeed];
    feed = nil;
    [self adjustRefreshTimer];

}

-(BOOL)alreadySubscribedToFeedURL:(NSURL*)URL
{
    BOOL result = NO;
    for (TSFeed *feed in [self.feedArrayController arrangedObjects]) {
        if ([feed.URL isEqualToURL:URL]) result = YES;
    }
    return result;
}


#pragma mark -
#pragma mark Feed Refresh Methods

-(void)adjustRefreshTimer
{
    NSInteger count = [[self.feedArrayController arrangedObjects] count];
    if (count == 0) {
        if (self.refreshTimer) {
            [self.refreshTimer invalidate];
            self.refreshTimer = nil;
        }
        return;
    }
    
    double refreshInterval;
    double refreshRaw;
    refreshRaw = 60.0*(ceil(count/12.0));
    if (refreshRaw > 300.0) refreshRaw = 300.0;
    refreshInterval = refreshRaw/(float)count;
    
    if (self.refreshTimer) [self.refreshTimer invalidate];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:refreshInterval
                                                         target:self selector:@selector(timerCallback:)
                                                       userInfo:nil
                                                        repeats:YES];
}

-(void)timerCallback:(NSTimer*)theTimer // theTimer ist erforderlich, weil Callback-Funktion
{
    NSInteger count = [[self.feedArrayController arrangedObjects] count];
    if (count == 0) return;
    if (self.refreshIndex >= count) self.refreshIndex = 0;
    TSFeed *feed = [[self.feedArrayController arrangedObjects] objectAtIndex:self.refreshIndex];
    refreshIndex++;
    if (!feed) return;
    if (feed.refreshing) return;
    feed.refreshing = YES;
    [feed checkForUpdate];
}


#pragma mark -
#pragma mark Feed Persistence & Migration Methods

-(void)loadFeeds
{
    // Init
    self.refreshIndex = 0;
    
    // Feeds laden
    if ([self checkForOldFileFormatVersion]) [self migrateFeeds]; // Prüfen, ob Feed-Datei migriert werden muss
    
    // Wenn schon Objekte im Controller sind, erst löschen, bevor neue geladen werden
    if ([[self.feedArrayController arrangedObjects] count] > 0) {
        [self.feedArrayController removeObjects:[self.feedArrayController arrangedObjects]];
    }
    
    // Feeds laden und dem Controller hinzufügen
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSWorkspace appDir]
                                                                         error:&error];
    [error logForClass:@"TSFeedController" method:@"loadFeeds"];
    if ((!files) || (error)) return;
    for (NSString *filename in files) {
        if ([filename hasSuffix:@".feed"]) {
            TSFeed *feed = [[TSFeed alloc] init];
            if ([feed loadWithFilename:filename]) [self addFeed:feed];
        }
    }
    
    // Sortierung
    if ([[self.feedArrayController sortDescriptors] count] == 0) {
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"title"
                                                           ascending:YES
                                                            selector:@selector(localizedCaseInsensitiveCompare:)];
        [self.feedArrayController setSortDescriptors:[NSArray arrayWithObject:sd]];
    }
    
    // UI nach Laden anpassen
    if ([[self.feedArrayController arrangedObjects] count] > 0) {
        [self.feedArrayController setSelectionIndex:0];
        [self.mainViewController scrollTableToTop];
        [self adjustRefreshTimer];
    }
    
}


// Prüfen, ob die Feeds im alten Dateiformat gespeichert sind
-(BOOL)checkForOldFileFormatVersion
{
    return ([[NSFileManager defaultManager] fileExistsAtPath:[NSWorkspace oldFeedPath]]);
}

// Feeds vom alten auf das neue Dateiformat migrieren
-(void)migrateFeeds
{
    // 1. Alte Feed-Datei auslesen
    NSError *error;
    
    NSData *dataRep = [NSData dataWithContentsOfFile:[NSWorkspace oldFeedPath]
                                             options:NSDataReadingUncached
                                               error:&error];
    [error logForClass:@"TSFeedController" method:@"migrateFeeds"];
    if (error) return;
    
    NSMutableArray *propertyList = [NSPropertyListSerialization propertyListWithData:dataRep
                                                                             options:NSPropertyListMutableContainersAndLeaves
                                                                              format:NULL
                                                                               error:&error];
    [error logForClass:@"TSFeedController" method:@"migrateFeeds"];
    
    if (error) return;
    
    for (NSDictionary *dict in propertyList) {
        TSFeed *feed = [[TSFeed alloc] init];
        
        // Feed-Daten übernehmen
        [feed setURL:[NSURL URLWithString:[dict valueForKey:@"url"]]];
        [feed setTitle:[dict valueForKey:@"title"]];
        [feed setLocalDateUpdated:[dict valueForKey:@"localDateUpdated"]];
        [feed setIcon:[[NSImage alloc] initWithData:[dict valueForKey:@"image"]]];
        if (!feed.icon) feed.icon = [NSImage imageNamed:@"replacementicon.png"];
        [feed setOriginalIcon:[[NSImage alloc] initWithData:[dict valueForKey:@"originalimage"]]];
        if (!feed.originalIcon) feed.originalIcon = [NSImage imageNamed:@"replacementicon.png"];
        
        // Feed speichern
        [feed saveFeed];
        
        // Entry-Hashes erzeugen (speichert Feed nochmal, aber das ist unvermeidlich)
        [feed checkForUpdate];
    }
    // 3. RefreshInterval neu berechnen
    [self adjustRefreshTimer];
    
    // 4. Alte Feed-Datei löschen
    NSString *backupPath = [[[NSWorkspace oldFeedPath] stringByDeletingPathExtension] stringByAppendingString:@".backup"];
    [[NSFileManager defaultManager] moveItemAtPath:[NSWorkspace oldFeedPath]
                                            toPath:backupPath
                                             error:&error];
    [error logForClass:@"TSFeedController" method:@"migrateFeeds"];
}


@end
