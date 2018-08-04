//
//  NSURL+Extensions.m
//  Monotony
//
//  Created by Tim Schröder on 17.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "NSURL+Extensions.h"

@implementation NSURL (Extensions)

// URL normalisieren
-(NSURL*)addScheme
{
    // URL Aus URLString erzeugen und ggf. Fehler zurückgeben
    NSString *urlString = [self absoluteString];
    NSURL *feedURL = self;
    NSArray *allowedSchemes = [NSArray arrayWithObjects: @"http",@"https",nil];
    if (self) {
        NSString *scheme = [self scheme];

        // Feed-Scheme ersetzen
        if ([scheme isEqualToString:@"feed"]) {
            
            // Feed-Prefix löschen
            NSRange r;
            r = [urlString rangeOfString:@"feed://"];
            if (r.location != NSNotFound) {
                if ([urlString length]>6) urlString = [urlString substringFromIndex:7];
                scheme = nil;
            } else {
                r = [urlString rangeOfString:@"feed:"];
                if (r.location != NSNotFound) {
                    if ([urlString length]>4) urlString = [urlString substringFromIndex:5];
                    scheme = nil;
                }
            }
            
            // Ggf. neues Scheme setzen
            r = [urlString rangeOfString:@"https://"];
            if (r.location != NSNotFound) {
                scheme = @"https";
                feedURL = [NSURL URLWithString: urlString];
            } else {
                r = [urlString rangeOfString:@"http://"];
                if (r.location != NSNotFound) {
                    scheme = @"http";
                    feedURL = [NSURL URLWithString: urlString];
                }
            }
        }
        
        if (scheme == nil) {
            urlString = [@"http://" stringByAppendingString:urlString];
            feedURL = [NSURL URLWithString: urlString];
            scheme = [feedURL scheme];
        }
        
        if( !allowedSchemes || [allowedSchemes containsObject: scheme] )
            if(!([[feedURL host] length] && [feedURL path]!=nil)) feedURL = nil;
    }
    return feedURL;
}

// Vergleicht zwei URLS miteinander
- (BOOL) isEqualToURL:(NSURL*)otherURL
{
    BOOL isEqual = NO;
    
    if ([[self absoluteURL] isEqual:[otherURL absoluteURL]]) isEqual = YES;
    if ([self isFileURL] && [otherURL isFileURL] && ([[self path] isEqual:[otherURL path]])) isEqual = YES;
    
    // Cover the case that feedURL has a trailing slash
    NSString *urlString = [self absoluteString];
    NSString *otherURLString = [otherURL absoluteString];
    if ([[urlString substringWithRange:NSMakeRange([urlString length]-1, 1)] isEqualToString:@"/"]) urlString = [urlString substringToIndex:[urlString length]-1];
    if ([[otherURLString substringWithRange:NSMakeRange([otherURLString length]-1, 1)] isEqualToString:@"/"]) otherURLString = [otherURLString substringToIndex:[otherURLString length]-1];
    if ([urlString isEqualToString:otherURLString]) isEqual = YES;
    return isEqual;
}

// Macht relative URLs zu absoluten URLs
-(NSURL*)expandRelativeLinkWithHost:(NSString*)host
{
    NSURL *expandedURL = self;
    NSString *urlString = [self absoluteString];
    if (![self scheme]) { // Nur expandieren, wenn URL unvollständig ist
        BOOL hasDivider = NO;
        if ([host hasSuffix:@"/"]) hasDivider = YES;
        if ([[self absoluteString] hasPrefix:@"/"]) hasDivider = YES;
        if (hasDivider) {
            expandedURL = [[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, urlString]] addScheme];
        } else {
            expandedURL = [[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", host, urlString]] addScheme];
        }
    }
    return expandedURL;
}


@end
