//
//  TSFeed.m
//  Monotony
//
//  Created by Tim Schröder on 18.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSFeed.h"
#import "TSKeychainItem.h"
#import "NSError+Log.h"
#import "NSWorkspace+Extensions.h"
#import "NSImage+Extensions.h"
#import "NSString+Extensions.h"
#import "NSDate+Extensions.h"
#import "TSDefaultsController.h"
#import "TSNotificationController.h"
#import "TSDataPush.h"


#define refreshIntervalMax 300 // entspricht fünf Minuten = Maximaler Abstand zwischen zwei Aktualisierungen eines Feeds
#define maxNumberOfHashes 300

@implementation TSFeed

@synthesize filename, URL, title, icon, originalIcon, localDateUpdated, entryHashes, refreshing, updateDate, protected, username, password, headerModifiedDate, contentModifiedDate;


#pragma mark -
#pragma mark Overriden Methods

- (id)init 
{
    if (self = [super init]) { // equivalent to "self does not equal nil"
        [self setTitle:@""];
        [self setURL:nil];
        [self setIcon:nil];
        [self setOriginalIcon:nil];
        [self setLocalDateUpdated:[NSDate dateWithTimeIntervalSinceNow:(refreshIntervalMax*-1)]];
        [self setEntryHashes:nil];
        [self setRefreshing:NO];
        [self setUpdateDate:[NSDate date]];
        [self setProtected:NO];
        [self setUsername:nil];
        [self setPassword:nil];
        [self setHeaderModifiedDate:nil];
        [self setContentModifiedDate:nil];
    }
    return self;
}


#pragma mark -
#pragma mark Initialization

// Called by TSSubscriptionController after new feed has been created
-(void) startOperationsWithNotification:(BOOL)withNotification
{
    // Entry identifiers erzeugen
    [self setRefreshing:YES];
    [self checkForUpdate]; // Speichert am Ende auch den Feed
    
    // Icon bearbeiten
    if (self.originalIcon) {
        self.icon = self.originalIcon;
        self.icon = [self.icon processAlpha];
    } else {
        self.icon = [NSImage imageNamed:@"replacementicon.png"];
        self.originalIcon = [NSImage imageNamed:@"replacementicon.png"];
    }
    
    if (withNotification) {
        // Confirmation Notification anzeigen
        NSString *summary = [NSString stringWithFormat:@"You're now subscribed to %@", self.title];
        NSString *okMessage = @"Subscription successful";
        [[TSNotificationController sharedController] displayNotificationWithTitle:okMessage
                                                                         subTitle:nil
                                                                          summary:summary
                                                                        URLString:nil
                                                                            image:nil];
    }
    [self checkForUpdate];
}


#pragma mark -
#pragma mark Persistence Methods

// Wird von TSMainController aufgerufen, wenn Feed beim Programmstart geladen wird
-(BOOL)loadWithFilename:(NSString*)name
{
    if (!name) return NO;
    if ([name length] == 0) return NO;
    NSError *error;
    NSString *path = [[NSWorkspace appDir] stringByAppendingPathComponent:name];
    NSData *dataRep = [NSData dataWithContentsOfFile:path
                                             options:NSDataReadingUncached
                                               error:&error];
    [error logForClass:@"TSFeed" method:@"loadWithFilename"];
    if (error) return NO;
    
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:dataRep
                                                                   options:NSPropertyListMutableContainersAndLeaves
                                                                    format:NULL
                                                                     error:&error];
    [error logForClass:@"TSFeed" method:@"loadWithFilename"];
    if ((error) || (!dict)) return NO;
    
    // Feed-Daten zusammensetzen
    self.filename = name;
    self.URL = [NSURL URLWithString:[dict valueForKey:@"url"]];
    self.title = [dict valueForKey:@"title"];
    self.localDateUpdated = [dict valueForKey:@"localDateUpdated"];
    if (!self.localDateUpdated) self.localDateUpdated = [NSDate date];
    self.icon = [[NSImage alloc] initWithData:[dict valueForKey:@"image"]];
    if (!self.icon) self.icon = [NSImage imageNamed:@"replacementicon.png"];
    self.originalIcon = [[NSImage alloc] initWithData:[dict valueForKey:@"originalimage"]];
    if (!self.originalIcon) self.originalIcon = [NSImage imageNamed:@"replacementicon.png"];
    self.entryHashes = [NSMutableArray arrayWithArray:[dict valueForKey:@"entryHashes"]];
    if (!self.entryHashes) self.entryHashes = [NSMutableArray arrayWithCapacity:0];
    /*
    if ([dict objectForKey:@"protected"]) {
        self.protected = [[dict objectForKey:@"protected"] boolValue];
        if (self.protected) {
            self.username = [dict valueForKey:@"username"];
            TSKeychainItem * keychainItem = [TSKeychainItem keychainItemForServer:[self.URL host]
                                                                         withPath:[self.URL path]
                                                                  withAccountName:self.username
                                                                         withPort:0
                                                              withSecProtocolType:kSecProtocolTypeHTTP
                                                                            error:&error];
            [error logForClass:@"TSFeed" method:@"loadWithFilename"];
            if (keychainItem) {
                self.password = [keychainItem password];
            }
        }
    }
     */
    [self checkForUpdate];
    return YES;
}

// Feed auf HDD speichern
-(void) saveFeed
{
    NSString *path = [self filePath];
    if (!path) return;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [self.icon TIFFRepresentation], @"image",
                          [self.originalIcon TIFFRepresentation], @"originalimage",
                          [self.URL absoluteString], @"url",
                          self.title, @"title",
                          self.localDateUpdated, @"localDateUpdated",
                          self.entryHashes, @"entryHashes",
                          [NSNumber numberWithBool:self.protected], @"protected",
                          self.username, @"username",
                          nil];
    NSData *data;
    NSError *error;
    data = [NSPropertyListSerialization dataWithPropertyList:dict
                                                      format:NSPropertyListXMLFormat_v1_0
                                                     options:0
                                                       error:&error];
    [error logForClass:@"TSFeed" method:@"save"];
    if (!error) {
        [data writeToFile:path atomically:NO];
    }
}

// Feed von HDD löschen
-(void) deleteFeed
{
    NSString *path = [self filePath];
    if (!path) return;
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    [error logForClass:@"TSFeed" method:@"delete"];
    
    // Ggf. Keychain Item löschen
    /*
    if (self.protected) {
        self.protected = NO;
        TSKeychainItem * keychainItem = [TSKeychainItem keychainItemForServer:[self.URL host]
                                                                     withPath:[self.URL path]
                                                              withAccountName:self.username
                                                                     withPort:0
                                                          withSecProtocolType:kSecProtocolTypeHTTP
                                                                        error:&error];
        if (keychainItem) [keychainItem deleteItem];
    }
     */
}


// Gibt vollständigen FilePath der Datei des TSFeed-Objekts zurück
-(NSString*)filePath
{
    if ((!self.filename) || ([self.filename length]==0)) { // Ggf. Filename erzeugen
        NSString *URLString = [self.URL absoluteString];
        if ((!URLString) || ([URLString length] == 0)) return nil;
        if ([URLString hasPrefix:@"http://"]) URLString = [URLString substringFromIndex:7];
        self.filename = [[[URLString stringByReplacingOccurrencesOfString:@":" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"-"] stringByAppendingString:@".feed"]; // Verbotene Zeichen : und / rausfiltern
    }
    NSString *path = [[NSWorkspace appDir] stringByAppendingPathComponent:self.filename];
    return path;
}


#pragma mark -
#pragma mark Refresh Methods

// Gibt Hash für einen Stringwert zurück
-(NSUInteger)hashForTitle:(NSString*)t
{
    return ([t hash]);
}

// Fügt neuen Hash zu Hash-Array hinzu, und löscht ggf. alte Hashes, wenn das Array voll ist
-(void)addHashToHashArray:(NSUInteger)hash
{
    // Prüfen, ob Wert schon im Array ist
    BOOL alreadyThere = NO;
    for (NSNumber *aHash in self.entryHashes) {
        if (!alreadyThere) {
            NSUInteger checkInt = [aHash integerValue];
            if (hash == checkInt) alreadyThere = YES;
        }
    }
    if (alreadyThere) return; // Wenn Wert schon vorhanden ist, nichts tun
    
    // Wenn Array voll ist, ältesten Wert rausschmeißen
    NSInteger count = [self.entryHashes count];
    if (count >= maxNumberOfHashes) {
        // Maximale Anzahl der Hashes im Array erreicht, ältesten Hash rausschmeißen und neuen am Ende hinzufügen
        do {
            [self.entryHashes removeObjectAtIndex:0];
            count--;
        } while (count>= maxNumberOfHashes);
    }
    
    // Neuen Wert hinzufügen
    [self.entryHashes addObject:[NSNumber numberWithInteger:hash]];
}

// Wird von MainController aufgerufen, prüft Feed auf Aktualisierung.
// Falls Aktualisierung: updateEntryHashesAndShowNotifications aufrufen
-(void)checkForUpdate
{
    self.updateDate = [NSDate date];
    double delta = [[NSDate date] timeIntervalSinceDate:self.localDateUpdated];
    if (delta > refreshIntervalMax) {
        // Letztes lokales Update zu lange her --> Alle Hashes neu berechnen
        [self updateEntryHashesAndShowNotifications:NO];
    } else {
        // Sonst: HEAD-Abfrage: Update des Feeds seit dem letzten Abruf?
        NSString *dateString = [self.localDateUpdated rfc1123StringFromDate];
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:self.URL
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:30.0];
        [theRequest setHTTPMethod:@"HEAD"];
        [theRequest setHTTPShouldHandleCookies:NO];
        [theRequest setValue:dateString forHTTPHeaderField:@"If-Modified-Since"];
        [NSURLConnection sendAsynchronousRequest:theRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error) {
                                       self.refreshing = NO;
                                       self.localDateUpdated = self.updateDate;
                                       return;
                                   }
                                   
                                   // Prüfen, wann lokale Hashes zum letzten Mal aktualisiert wurden
                                   BOOL modified = YES;
                                   NSInteger statusCode = 0;
                                   if ([response respondsToSelector:@selector(statusCode)]) {
                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                                       statusCode = [httpResponse statusCode];
                                       if (statusCode == 304) modified = NO; // 304 = Not Modified
                                       if (statusCode == 200) { // 200 = OK, weiter testen
                                           if ([response respondsToSelector:@selector(allHeaderFields)]) {
                                               NSString *lastModifiedString = [[httpResponse allHeaderFields] objectForKey:@"Last-Modified"];
                                               if (lastModifiedString) {
                                                   NSDate *serverDate = [NSDate dateFromRFC1123:lastModifiedString];
                                                   if (serverDate) {
                                                       if (self.headerModifiedDate) {
                                                           if (!([serverDate compare:self.headerModifiedDate]== NSOrderedDescending)) modified = NO;
                                                       }
                                                       self.headerModifiedDate = serverDate;
                                                   }
                                               }
                                           }
                                       }
                                   }
                                   
                                   if (modified) { // Feed wurde geändert, updateEntryHashesAndShowNotifications: aufrufen
                                       [self updateEntryHashesAndShowNotifications:YES];
                                   } else {
                                       self.refreshing = NO;
                                       self.localDateUpdated = self.updateDate;
                                   }
                               }];


    }
}

// Lädt Feedinhalt,
// löscht lokal vorhandene, auf dem Server nicht mehr vorhandene Hashes
// Fügt auf dem Server neu vorhandene, lokal noch nicht vorhandene Hashes hinzu
// Wenn showNotifications = YES, zeigt es für neue Hashes Notifications an
// Wenn showNotifications = NO, berechnet es alle Hashes neu, zeigt aber nichts an
// showNotifications wird von checkForUpdate auf NO gesetzt, wenn letzte Aktualisierung zu lange her ist
-(void)updateEntryHashesAndShowNotifications:(BOOL)showNotifications
{
    // Debug Flag, if Yes, will print all Debug Info
    BOOL debug = NO;
    /*
    NSRange aRange;
    aRange = [[self.URL absoluteString] rangeOfString:@"xkcd"];
    if (aRange.location != NSNotFound) {
        NSLog (@"Debugging %@", self.title);
        debug = YES;
    }
     */
    
    if (!self.entryHashes) self.entryHashes = [NSMutableArray arrayWithCapacity:0];
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:self.URL
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:30.0];
    [theRequest setHTTPShouldHandleCookies:NO];
    [NSURLConnection sendAsynchronousRequest:theRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                               if (error) {
                                   self.refreshing = NO;
                                   return;
                               }
                                                            
                               NSInteger statusCode = 0;
                               if ([response respondsToSelector:@selector(statusCode)]) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                                   statusCode = [httpResponse statusCode];
                               }
                               if ((data) && (statusCode == 200)) {
                                   BOOL changedSomething = NO;

                                   NSXMLDocument *xmlDoc;
                                   NSError *error;
                                   xmlDoc = [[NSXMLDocument alloc] initWithData:data
                                                                        options:NSXMLDocumentTidyXML
                                                                          error:&error]; // Error ignorieren, da können auch nur Warnungen drin sein

                                   if (!xmlDoc) { // Bug Fix 1.4.0 - Error-Abfrage ist unzuverlässig
                                       self.refreshing = NO;
                                       return;
                                   }
                                   
                                   // Wenn ShowNotification == YES:
                                   if ((showNotifications) || (debug)) {
                                       // Zuerst ermitteln, ob Last Change Datum des Feeds auf dem Server > (refreshInterval*2) zurück ist!
                                       // Falls ja: Feed wurde nicht aktualisiert, fertig
                                       // Falls nein: Feed wurde aktualisiert: Weiter
                                       NSDate *pubDate;
                                       NSDate *lastBuildDate;
                                       NSDate *changedDate;
                                       NSArray *pubDateNodes = [xmlDoc nodesForXPath:@"//channel/pubDate" error:&error];
                                       if ([pubDateNodes count]>0) {
                                           pubDate = [NSDate dateFromRFC1123:[[pubDateNodes objectAtIndex:0] stringValue]];
                                       }
                                       NSArray *lastBuildNodes= [xmlDoc nodesForXPath:@"//channel/lastBuildDate" error:&error];
                                       if ([lastBuildNodes count]>0) {
                                           lastBuildDate = [NSDate dateFromRFC1123:[[lastBuildNodes objectAtIndex:0] stringValue]];
                                       }
                                       NSArray *changedNodes= [xmlDoc nodesForXPath:@"//feed/changed" error:&error];
                                       if ([changedNodes count]>0) {
                                           changedDate = [NSDate dateFromRFC1123:[[changedNodes objectAtIndex:0] stringValue]];
                                       }
                                       NSDate *modDate;
                                       if (pubDate) modDate = pubDate;
                                       if (changedDate) modDate = changedDate;
                                       if (lastBuildDate) modDate = lastBuildDate;
                                       if ((modDate) && (!debug)) {
                                           if (self.contentModifiedDate) {
                                               if (!([modDate compare:self.contentModifiedDate]==NSOrderedDescending)) {
                                                   self.refreshing = NO;
                                                   self.localDateUpdated = self.updateDate;
                                                   return;
                                               }
                                           }
                                           self.contentModifiedDate = modDate;
                                       }
                                                                              
                                       // Alle neuen bzw. geänderten Items ermitteln
                                       NSArray *items;
                                       items = [xmlDoc nodesForXPath:@"//item" error:&error];
                                       if ([items count]==0) {
                                           items = [xmlDoc nodesForXPath:@"//entry" error:&error];
                                       }
                                       
                                       if (debug) NSLog (@"number of entries: %li", [items count]);
                                       
                                       // Titel ermitteln
                                       BOOL partialChange = NO;
                                       for (NSXMLNode *item in items) {
                                           NSArray *titles = [item nodesForXPath:@".//title" error:&error];
                                           NSString *titleString = @"";
                                           if ([titles count]>0) {
                                               titleString = [[[titles objectAtIndex:0] stringValue] stringByStrippingHTML];
                                           }
                                           NSUInteger hash = [self hashForTitle:titleString];
                                           BOOL hashAlreadyThere = NO;
                                           for (NSNumber *compareHashNumber in self.entryHashes) {
                                               NSUInteger compareHash = [compareHashNumber integerValue];
                                               if (hash == compareHash) hashAlreadyThere = YES;
                                           }
                                           if (debug) NSLog (@"title: %@", titleString);
                                           if ((!hashAlreadyThere) || (debug)) { // Notification senden
                                               partialChange = YES;
                                               
                                               // Neuen Hash speichern
                                               [self addHashToHashArray:hash];
                                               
                                               // URL rauskriegen
                                               NSString *linkString = @"";
                                               NSArray *links = [item nodesForXPath:@".//link" error:&error];
                                               if ([links count]>0) {
                                                   linkString = [[links objectAtIndex:0] stringValue];
                                                   if ([linkString length]==0) { // www.daringfireball.net u.a.
                                                       linkString = [[[links objectAtIndex:0] attributeForName:@"href"] stringValue];
                                                       for (NSXMLElement *element in links) {
                                                           if ([[[element attributeForName:@"rel"] stringValue] isEqualToString:@"shorturl"]) linkString = [[element attributeForName:@"href"] stringValue];
                                                       }
                                                   }
                                               }
                                               if (debug) NSLog (@"link: %@", linkString);
                                               
                                               // Link-String formatieren (für NSURL ungültige Zeichen rausfiltern)
                                               NSRange semiR;
                                               semiR = [linkString rangeOfString:@";"];
                                               if (semiR.location != NSNotFound) {
                                                   linkString = [linkString substringToIndex:semiR.location];
                                               }
                                               semiR = [linkString rangeOfString:@"#"];
                                               if (semiR.location != NSNotFound) {
                                                   linkString = [linkString substringToIndex:semiR.location];
                                               }
                                               linkString = [linkString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                               
                                               // Content rauskriegen
                                               NSString *summaryString = @"";
                                               NSArray *summaries;
                                               summaries = [item nodesForXPath:@".//summary" error:&error];
                                               if ([summaries count]==0) {
                                                   summaries = [item nodesForXPath:@".//description" error:&error];
                                               }
                                               if ([summaries count]==0) {
                                                   summaries = [item nodesForXPath:@".//content" error:&error];
                                               }
                                               if ([summaries count]==0) {
                                                   summaries = [item nodesForXPath:@".//content:encoded" error:&error];
                                               }
                                               if ([summaries count]>0) {
                                                   summaryString = [[[summaries objectAtIndex:0] stringValue] stringByStrippingHTML];
                                                   if ([summaryString length]>150) {
                                                       summaryString = [summaryString substringToIndex:150];
                                                       summaryString = [summaryString stringByAppendingString:@" .."];
                                                   }
                                               }
                                               
                                               // Notification senden
                                               if ([titleString length] > 0) {
                                                   [[TSNotificationController sharedController] displayNotificationWithTitle:titleString
                                                                                                                    subTitle:self.title
                                                                                                                     summary:summaryString
                                                                                                                   URLString:linkString
                                                                                                                       image:self.originalIcon];
                                                   TSDataPush *dataPush = [[TSDataPush alloc] init];
                                                   [dataPush pushNotificationWithTitle:titleString];
                                               }
                                           }
                                       }
                                       // Änderungen speichern
                                       if (partialChange) {
                                           changedSomething = YES;
                                       }
                                   } else { // Alle Entry Hashes neu speichern, nichts anzeigen
                                       
                                       changedSomething = YES; // In jedem Fall speichern
                                       // Alle Hashes ermitteln
                                       NSArray *items;
                                       items = [xmlDoc nodesForXPath:@"//item" error:&error];
                                       if ([items count]==0) {
                                           items = [xmlDoc nodesForXPath:@"//entry" error:&error];
                                       }
                                       
                                       // Titel  ermitteln
                                       for (NSXMLNode *item in items) {
                                           NSArray *titles = [item nodesForXPath:@".//title" error:&error];
                                           NSString *titleString = @"";
                                           if ([titles count]>0) titleString = [[[titles objectAtIndex:0] stringValue] stringByStrippingHTML];
                                           NSUInteger hash = [self hashForTitle:titleString];
                                           [self addHashToHashArray:hash];
                                       }
                                   }
                                   
                                   // Feed speichern
                                   self.localDateUpdated = self.updateDate;
                                   if (changedSomething) [self saveFeed];
                               }
                               self.refreshing = NO;
                           }];
}


@end
