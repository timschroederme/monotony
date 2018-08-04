//
//  TSFeed.h
//  Monotony
//
//  Created by Tim Schröder on 18.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>


@class TSKeychainItem;

@interface TSFeed : NSObject

-(BOOL) loadWithFilename:(NSString*)name;
-(void) startOperationsWithNotification:(BOOL)withNotification;
-(void) saveFeed;
-(void) deleteFeed;
-(void) checkForUpdate;

@property (strong) NSString *filename;
@property (strong) NSURL *URL;
@property (strong) NSString *title;
@property (strong) NSImage *icon;
@property (strong) NSImage *originalIcon;
@property (strong) NSDate *localDateUpdated;
@property (strong) NSMutableArray *entryHashes;
@property (assign) BOOL refreshing;
@property (strong) NSDate *updateDate;
@property (assign) BOOL protected;
@property (strong) NSString *username;
@property (strong) NSString *password;
@property (strong) NSDate *headerModifiedDate;
@property (strong) NSDate *contentModifiedDate;

@end
