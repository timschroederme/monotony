//
//  TSFeedController.h
//  Monotony
//
//  Created by Tim Schröder on 26.12.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSMainViewController, TSFeed;

@interface TSFeedController : NSObject

-(NSURL*)URLForTableRow:(NSInteger)row;
-(NSInteger)selectionIndex;
-(void)saveSelectedFeedAndRearrange;
-(NSArray*)allFeeds;

-(void)adjustRefreshTimer;
-(void) addFeedWithURL:(NSURL*)feedURL
                  icon:(NSImage*)icon
                 title:(NSString*)title
              username:(NSString*)username
      showNotification:(BOOL)showNotification;
-(void)unsubscribeFromSelectedFeed;
-(BOOL)alreadySubscribedToFeedURL:(NSURL*)URL;
-(void)loadFeeds;

@property (assign) IBOutlet NSArrayController *feedArrayController;
@property (assign) IBOutlet TSMainViewController *mainViewController;
@property (strong) NSTimer *refreshTimer;
@property (assign) NSInteger refreshIndex;


@end
