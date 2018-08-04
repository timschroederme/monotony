//
//  TSSubscriptionController.h
//  Monotony
//
//  Created by Tim Schröder on 17.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSSubscriptionProtocol.h"

@class TSSubscriptionViewController, TSFeedController, TSSubscription;

@interface TSSubscriptionController : NSObject <TSSubscriptionProtocol>

- (void) showSubscriptionWindowWithURL:(NSURL*)URL;
- (void) startSubscriptionWithURL:(NSURL*)URL;
- (void) importURLs:(NSArray*)urlArray;
- (void) cancelSubscription;

@property (assign) IBOutlet TSSubscriptionViewController *subscriptionViewController;
@property (assign) IBOutlet TSFeedController *feedController;

@property (assign) BOOL importing;
@property (strong) NSMutableArray *importQueue;
@property (assign) NSInteger importCount;
@property (assign) NSInteger importIdx;
@property (assign) NSInteger importSuccessCount;

@property (strong) TSSubscription *subscription;

@end
