//
//  TSSubscription.m
//  Monotony
//
//  Created by Tim Schröder on 02.01.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import "TSSubscription.h"
#import "TSSubscriptionProtocol.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"

@implementation TSSubscription

typedef enum {
    RSS,
    Atom,
    HTML,
    unknown
} parseType;


#pragma mark -
#pragma mark Public Methods

-(void) startSubscriptionWithURL:(NSURL*)URL
{
    // Prepare Variables
    self.feedIconIdx = 0;
    self.feedProcessCount = 0;
    self.cancelled = NO;
    self.feedURL = URL;
    if (!self.feedIconLinks) {
        self.feedIconLinks = [NSMutableArray arrayWithCapacity:0];
    } else {
        [self.feedIconLinks removeAllObjects]; // Kann passieren, weil die Methode mehrfach aufgerufen wird
    }
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:URL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:30.0];
    [theRequest setHTTPShouldHandleCookies:NO];
    
    [NSURLConnection sendAsynchronousRequest:theRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSInteger statusCode = 0;
                               if ([response respondsToSelector:@selector(statusCode)]) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                                   statusCode = [httpResponse statusCode];
                               }
                               
                               if (statusCode == 200) {
                                   [self parseData:data];
                                   return;
                               }
                               if (error) {
                                   
                                   // Protected Feed Error?
                                   if (([[error domain] isEqualToString:NSURLErrorDomain]) && (([error code]==NSURLErrorUserAuthenticationRequired) || ([error code]== NSURLErrorUserCancelledAuthentication))) {
                                       [self sendAskForCredentialsToDelegate];
                                       return;
                                   }
                               }
                               
                                // Pass on error message to delegate
                                [self sendErrorToDelegate:error];
                           }];

}


-(void) cancelSubscription
{
    self.cancelled = YES;
}

#pragma mark -
#pragma mark TSSubscriptionProtocol Communication Methods

-(void)sendAskForCredentialsToDelegate
{
    if (self.cancelled) return;
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(TSSubscriptionProtocol)] && [self.delegate respondsToSelector:@selector(askForCredentials)]) [self.delegate askForCredentials];
}

-(void)sendErrorToDelegate:(NSError*)error
{
    if (self.cancelled) return;
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(TSSubscriptionProtocol)] && [self.delegate respondsToSelector:@selector(subscriptionFailedWithError:)]) [self.delegate subscriptionFailedWithError:error];
}

-(void)sendChooseFromFeedsToDelegate:(NSArray*)feeds
{
    if (self.cancelled) return;
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(TSSubscriptionProtocol)] && [self.delegate respondsToSelector:@selector(chooseFromFeeds:)]) [self.delegate chooseFromFeeds:feeds];
}

-(void)sendSubscriptionSucceededToDelegate
{
    if (self.cancelled) return;
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(TSSubscriptionProtocol)] && [self.delegate respondsToSelector:@selector(subscriptionSucceededWithURL:icon:title:)]) [self.delegate subscriptionSucceededWithURL:self.feedURL icon:self.feedIcon title:self.feedTitle];
}


#pragma mark -
#pragma mark Feed Parsing Methods

-(void)parseData:(NSData*)feedData
{
    parseType pt = unknown;
    NSError *error;
    if (!feedData) {
        [self sendErrorToDelegate:nil];
        return;
    }
    
    // Entscheiden, welche Parse-Methode verwendet wird
    NSXMLDocument *xmlDoc;
    NSString *host = [self.feedURL host];
    NSURL *compareURL = [[NSURL URLWithString:host] addScheme];
        
    // Parsen
    if ([self.feedURL isEqualToURL:compareURL]) {
        self.feedURL = compareURL; // Fix for trailing slash bug
        xmlDoc = [[NSXMLDocument alloc] initWithData:feedData
                                             options:NSXMLDocumentTidyHTML|NSXMLDocumentTidyXML
                                               error:&error];
    } else {
        xmlDoc = [[NSXMLDocument alloc] initWithData:feedData
                                             options:NSXMLDocumentTidyXML
                                               error:&error];
    }
    
    //if (error) NSLog (@"Error: %@", [error localizedDescription]);
    NSXMLElement *element = [xmlDoc rootElement];
    NSString *name = [[element name] lowercaseString];
    if ([name isEqualToString:@"html"]) pt = HTML;
    if ([name isEqualToString:@"rss"]) pt = RSS;
    if ([name isEqualToString:@"feed"]) pt = Atom;
    NSRange r = [name rangeOfString:@"rdf"];
    if (r.location != NSNotFound) pt = RSS;
    if (pt==unknown) {
        NSString *xmlString = [element XMLString];
        if (xmlString) {
            NSRange r;
            r = [xmlString rangeOfString:@"http://www.w3.org/2005/Atom"];
            if (r.location != NSNotFound) pt = Atom;
            r = [xmlString rangeOfString:@"application/atom+xml"];
            if (r.location != NSNotFound) pt = Atom;
            r = [xmlString rangeOfString:@"http://purl.org/atom/"];
            if (r.location != NSNotFound) pt = Atom;
            r = [xmlString rangeOfString:@"http://purl.org/rss/"];
            if (r.location != NSNotFound) pt = RSS;
        }
    }
    
    switch (pt) {
        case HTML:
            [self parseHTML:xmlDoc];
            break;
            
        case RSS:
            [self parseFeed:xmlDoc];
            break;
            
        case Atom:
            [self parseFeed:xmlDoc];
            break;
            
        default:
            [self sendErrorToDelegate:nil];
            break;
    }
}

-(void)parseHTML:(NSXMLDocument*)xmlDoc
{    
    // 1. Feed-Links suchen
    NSError *error;
    NSArray *alternateNodes = [xmlDoc nodesForXPath:@".//link[@rel='alternate'][@type='application/rss+xml' or @type='application/atom+xml']" error:&error];
    if (!alternateNodes) {
        [self sendErrorToDelegate:nil];
        return;
    }
    
    if ([alternateNodes count]==0) {
        NSDictionary *errorDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Sorry, Monotony didn't find any feed URLs on this page.", NSLocalizedDescriptionKey, nil];
        NSError *error;
        error = [NSError errorWithDomain:@"Monotony Error" code:-1 userInfo:errorDictionary];
        [self sendErrorToDelegate:error];
    }
    
    // 2. Image-Links auswerten
    [self.feedIconLinks addObject:[[self.feedURL host] stringByAppendingString:@"/favicon.ico"]];
    NSArray *imageNodes = [xmlDoc nodesForXPath:@"//link/@href" error:&error];
    if (!error) [self addLinksToImageLinkArray:imageNodes];
    
    // 3. Mit Abonnieren fortfahren oder Auswahlfenster anzeigen
    if ([alternateNodes count] == 1) {
        NSString *urlString = [[[alternateNodes objectAtIndex:0] attributeForName:@"href"] stringValue];
        NSURL *URL = [NSURL URLWithString:urlString];
        URL = [URL expandRelativeLinkWithHost:[self.feedURL host]];
        [self startSubscriptionWithURL:URL]; // Neu starten
        
        // Auswahlfenster anzeigen
    } else {
        NSMutableArray *choices = [NSMutableArray arrayWithCapacity:[alternateNodes count]];
        NSInteger __block choiceCount = 0;
        int i;
        for (i=0;i<[alternateNodes count];i++) {
            NSString *urlString = [[[alternateNodes objectAtIndex:i] attributeForName:@"href"] stringValue];
            NSURL *URL = [NSURL URLWithString:urlString];
            URL = [URL expandRelativeLinkWithHost:[self.feedURL host]];
            
            // Für jeden Link die entsprechende Page laden und den Titel extrahieren
            NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:URL
                                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                timeoutInterval:30.0];
            [theRequest setHTTPShouldHandleCookies:NO];
            [NSURLConnection sendAsynchronousRequest:theRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       NSInteger statusCode = 0;
                                       if ([response respondsToSelector:@selector(statusCode)]) {
                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                                           statusCode = [httpResponse statusCode];
                                       }
                                       if (!error) {
                                           NSXMLDocument *titleDoc = [[NSXMLDocument alloc] initWithData:data
                                                                                                 options:NSXMLDocumentTidyHTML
                                                                                                   error:&error];
                                           NSString *urlTitle = @"unknown";
                                           if (statusCode == 200) {
                                               NSArray *nodes = [titleDoc nodesForXPath:@"//title[1]" error:&error];
                                               if (!((error) || ([nodes count]==0))) {
                                                   urlTitle = [[[nodes objectAtIndex:0] stringValue] stringByStrippingHTML];
                                               }
                                           } else {
                                               urlTitle = [[[alternateNodes objectAtIndex:i] attributeForName:@"title"] stringValue];
                                           }
                                           // Prüfen, ob es URL schon im Dict gibt (kommt vor, z.B. cultofmac.com)
                                           BOOL URLAlreadyThere = NO;
                                           for (NSDictionary *compareDict in choices) {
                                               if ([[compareDict objectForKey:@"urlString"] isEqualToString:[URL absoluteString]]) URLAlreadyThere = YES;
                                           }
                                           
                                           // Nein, in Dict aufnehmen
                                           if (!URLAlreadyThere) {
                                               NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:urlTitle, @"title", [URL absoluteString], @"urlString", nil];
                                               [choices addObject:dict];
                                           }
                                       }
                                       choiceCount++;
                                       
                                       // Wenn alle Titel geladen sind, Auswahlfenster anzeigen (oder gleich weiter, wenn nur 1 Feed)
                                       if (choiceCount==([alternateNodes count])) {
                                           if ([choices count] > 1) {
                                               [self sendChooseFromFeedsToDelegate:choices];
                                           } else {
                                               [self startSubscriptionWithURL:URL];
                                           }
                                       }
                                   }];
        }
    }
}

-(void)parseFeed:(NSXMLDocument*)xmlDoc
{    
    // 1. Titel ermitteln
    NSError *error;
    NSArray *nodes = [xmlDoc nodesForXPath:@"//title[1]" error:&error];
    if ((error) || ([nodes count]==0)) {
        [self sendErrorToDelegate:error];
        return;
    }
    self.feedTitle = [[[nodes objectAtIndex:0] stringValue] stringByStrippingHTML];
    
    // 1a. Link ermitteln // Bug Fix in V 1.4.3
    NSArray *linkNodes = [xmlDoc nodesForXPath:@"//link[1]" error:&error];
    if (error) {
        [self sendErrorToDelegate:error];
    } else {
        if ([linkNodes count]>0) self.feedLink = [[[linkNodes objectAtIndex:0] stringValue] stringByStrippingHTML];
    }
    
    // 2. Icon ermitteln
    
    // 2.0.1 FeedLink auswerten
    if (self.feedLink) {
        NSURL *linkURL = [NSURL URLWithString:self.feedLink];
        if ((linkURL) && ([linkURL host])) {
            [self.feedIconLinks addObject:[[linkURL host] stringByAppendingString:@"/favicon.ico"]];
            [self.feedIconLinks addObject:[[linkURL host] stringByAppendingString:@"/favicon.png"]];
        }
    }
    
    // 2.1. Sonderregel für Feedburner-Feeds
    NSRange feedBurnerRange;
    feedBurnerRange = [[self.feedURL absoluteString] rangeOfString:@"feedburner.com"];
    if (feedBurnerRange.location != NSNotFound) {
        NSArray *feedBurnerLinks = [xmlDoc nodesForXPath:@"//link" error:&error];
        if (!error) {
            if ([feedBurnerLinks count]>0) {
                NSString *link;
                NSArray *attributes = [[feedBurnerLinks objectAtIndex:0] attributes];
                if (attributes) {
                    NSString *name = [[attributes objectAtIndex:0] name];
                    if ([name isEqualToString:@"href"]) link = [[attributes objectAtIndex:0] stringValue];
                } else {
                    link = [[feedBurnerLinks objectAtIndex:0] stringValue];
                }
                
                if (link) {
                    [self.feedIconLinks addObject:link];
                    NSString *host = [[NSURL URLWithString:link] host];
                    [self.feedIconLinks addObject:[host stringByAppendingString:@"/favicon.ico"]]; //apple-touch-icon.png apple-touch-icon-precomposed.png
                    [self.feedIconLinks addObject:[host stringByAppendingString:@"/favicon.png"]]; //apple-touch-icon.png apple-touch-icon-precomposed.png
                }
            }
        }
    }
    
    // 2.2. Favicon suchen
    [self.feedIconLinks addObject:[[self.feedURL host] stringByAppendingString:@"/favicon.ico"]];
    [self.feedIconLinks addObject:[[self.feedURL host] stringByAppendingString:@"/favicon.png"]];
    [self.feedIconLinks addObject:[[self.feedURL host] stringByAppendingString:@"/apple-touch-icon.png"]];
    [self.feedIconLinks addObject:[[self.feedURL host] stringByAppendingString:@"/apple-touch-icon-precomposed.png"]];
    if ([[self.feedURL host] hasPrefix:@"rss"]) { // Bug Fix 1.4.0 für Golem.de usw.
        NSString *secondHost = [NSString stringWithFormat:@"%@", [[self.feedURL host] substringFromIndex:4]];
        [self.feedIconLinks addObject:[secondHost stringByAppendingString:@"/favicon.ico"]];
        [self.feedIconLinks addObject:[secondHost stringByAppendingString:@"/favicon.png"]];
        [self.feedIconLinks addObject:[secondHost stringByAppendingString:@"/apple-touch-icon.png"]];
        [self.feedIconLinks addObject:[secondHost stringByAppendingString:@"/apple-touch-icon-precomposed.png"]];
    }
    
    // 2.3. Image-Links suchen
    NSArray *imageNodes = [xmlDoc nodesForXPath:@"//image/url" error:&error];
    if ((!error) && ([imageNodes count]>0)) {
        NSString *urlString = [[imageNodes objectAtIndex:0] stringValue];
        NSURL *URL = [NSURL URLWithString:urlString];
        URL = [URL expandRelativeLinkWithHost:[self.feedURL host]];
        [self.feedIconLinks addObject:[URL absoluteString]];
    }
    
    // 2.4. weitere mögliche Image-Links suchen
    NSArray *moreImageNodes = [xmlDoc nodesForXPath:@"//link" error:&error];
    if ((!error) && ([moreImageNodes count]>0)) {
        NSString *urlString = [[moreImageNodes objectAtIndex:0] stringValue];
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30.0];
        [theRequest setHTTPShouldHandleCookies:NO];
        [NSURLConnection sendAsynchronousRequest:theRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   NSInteger statusCode = 0;
                                   if ([response respondsToSelector:@selector(statusCode)]) {
                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                                       statusCode = [httpResponse statusCode];
                                   }
                                   if (!error) {
                                       
                                       NSXMLDocument *imageDoc = [[NSXMLDocument alloc] initWithData:data
                                                                                             options:NSXMLDocumentTidyHTML
                                                                                               error:&error];
                                       if (statusCode == 200) {
                                           NSArray *imageNodes = [imageDoc nodesForXPath:@"//head/link/@href" error:&error];
                                           [self addLinksToImageLinkArray:imageNodes];
                                       }
                                   }
                                   [self loadFeedImage];
                               }];
    } else {
        [self loadFeedImage];
    }
}


#pragma mark -
#pragma mark Image Methods


-(void)loadFeedImage
{
    if (self.cancelled) return; // Wenn abgebrochen wurde, nicht mehr weitermachen
    if ([self.feedIconLinks count] == 0) self.feedIcon = [NSImage imageNamed:@"replacementicon.png"];
    if (self.feedIconIdx >= [self.feedIconLinks count]) [self sendSubscriptionSucceededToDelegate];
    NSString *urlString = [self.feedIconLinks objectAtIndex:self.feedIconIdx];
    self.feedIconIdx++;
    NSURL *URL = [[NSURL URLWithString:urlString] addScheme];
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:URL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:30.0];
    [theRequest setHTTPShouldHandleCookies:NO];
    [NSURLConnection sendAsynchronousRequest:theRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               BOOL ok = NO;
                               if (!error) {
                                   if (data) {
                                       self.feedIcon = [[NSImage alloc] initWithData:data];
                                       if (self.feedIcon) ok = YES;
                                       self.feedIcon.size = NSMakeSize(16.0, 16.0); // Bug Fix 1.4.0
                                   }
                               }
                               if ((ok) || (self.feedIconIdx >= [self.feedIconLinks count])) {
                                   [self sendSubscriptionSucceededToDelegate];
                               } else {
                                   [self loadFeedImage];
                               }
                           }];
}


// Wertet das XMLNode-Array auf Image-Links aus, fügt die Links der globalen Variable zu
// Gibt YES zurück, wenn wenigstens ein Image gefunden wurde, sonst NO
-(BOOL)addLinksToImageLinkArray:(NSArray*)nodes
{
    BOOL result = NO;
    if (!nodes) return result;
    if ([nodes count]==0)return result;
    int i;
    for (i=0;i<[nodes count];i++) {
        NSString *urlString = [[nodes objectAtIndex:i] stringValue];
        if (![urlString isEqualToString:[self.feedURL absoluteString]]) {
            if (([urlString hasSuffix:@".png"]) || ([urlString hasSuffix:@".gif"]) || ([urlString hasSuffix:@".tif"]) || ([urlString hasSuffix:@".jpg"]) || ([urlString hasSuffix:@".ico"])) {
                NSURL *URL = [NSURL URLWithString:urlString];
                URL = [URL expandRelativeLinkWithHost:[self.feedURL host]];
                [self.feedIconLinks addObject:[URL absoluteString]];
                result = YES;
            }
        }
    }
    return result;
}


@end
