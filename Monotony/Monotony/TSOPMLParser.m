//
//  TSOPMLParser.m
//  Monotony
//
//  Created by Tim Schröder on 01.01.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import "TSOPMLParser.h"
#import "TSFeed.h"

@implementation TSOPMLParser

-(BOOL)exportFeedURLs:(NSArray*)feeds toLocation:(NSURL*)URL
{
    NSError *error;
    
    // Dokument erzeugen
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithXMLString:@"<opml version=""1.0"">" options:NSXMLDocumentTidyXML error:&error];
    if (error) return NO;
    NSXMLElement *root = [xmlDoc rootElement];
    
    // Head erzeugen
    NSXMLElement *headNode = [NSXMLElement elementWithName:@"head"];
    [root addChild:headNode];
    NSXMLNode *titleNode = [NSXMLNode elementWithName:@"title"];
    [titleNode setStringValue:@"Monotony Feed Subscriptions"];
    [headNode addChild:titleNode];
    
    // Body erzeugen
    NSXMLElement *bodyNode = [NSXMLElement elementWithName:@"body"];
    [root addChild:bodyNode];
    
    // Einträge einbauen
    for (TSFeed *feed in feeds) {
        NSXMLElement *outline = [NSXMLElement elementWithName:@"outline"];
        NSXMLNode *text = [NSXMLNode attributeWithName:@"text" stringValue:feed.title];
        NSXMLNode *title = [NSXMLNode attributeWithName:@"title" stringValue:feed.title];
        NSXMLNode *type = [NSXMLNode attributeWithName:@"type" stringValue:@"rss"];
        NSXMLNode *xmlURL = [NSXMLNode attributeWithName:@"xmlUrl" stringValue:[feed.URL absoluteString]];
        [outline addAttribute:text];
        [outline addAttribute:title];
        [outline addAttribute:type];
        [outline addAttribute:xmlURL];
        [bodyNode addChild:outline];
    }
    
    // Dokument auf HDD speichern
    NSString *xmlString = [xmlDoc XMLStringWithOptions:NSXMLNodePrettyPrint];
    NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    [xmlData writeToFile:[URL path] atomically:NO];
    return YES;
}

-(NSArray*)importFeedsFromLocation:(NSURL*)URL
{
    if (!URL) return nil;
    
    // OPML-Datei einlesen
    NSData *xmlData = [NSData dataWithContentsOfFile:[URL path]];
    if (!xmlData) return nil;
    NSError *error;
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithData:xmlData
                                         options:NSXMLDocumentTidyXML
                                           error:&error];
    if ((error) || (!xmlDoc)) return nil;
    
    // OPML-Daten parsen
    NSMutableArray *URLArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *nodes = [xmlDoc nodesForXPath:@"//outline" error:&error];
    if ((error) || (!nodes) || ([nodes count]==0)) return nil;
    for (NSXMLNode *node in nodes) {
        NSXMLElement *element = (NSXMLElement*)node;
        NSString *urlString = [[element attributeForName:@"xmlUrl"] stringValue];
        if (urlString) {
            NSURL *oneURL = [NSURL URLWithString:urlString];
            if (oneURL) [URLArray addObject:oneURL];
        }
    }
    if ([URLArray count] == 0) return nil;
    return URLArray;
}


@end
