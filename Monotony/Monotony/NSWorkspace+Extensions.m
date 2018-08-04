//
//  NSWorkspace+Extensions.m
//  Monotony
//
//  Created by Tim Schröder on 17.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "NSWorkspace+Extensions.h"

@implementation NSWorkspace (Extensions)

// Gibt das App-Verzeichnis zurück
+(NSString*)appDir
{
    return ([NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]);
}

// Gibt den Pfad zum Speicherort der gespeicherten Feeds zurück
+(NSString*) oldFeedPath
{
    return ([[self appDir] stringByAppendingPathComponent:@"feeds.plist"]);
}

@end
