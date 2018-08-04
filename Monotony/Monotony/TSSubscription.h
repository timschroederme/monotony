//
//  TSSubscription.h
//  Monotony
//
//  Created by Tim Schröder on 02.01.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSSubscription : NSObject

-(void) startSubscriptionWithURL:(NSURL*)URL;
-(void) cancelSubscription;

@property (assign) id delegate;
@property (strong) NSURL *feedURL;
@property (strong) NSString *feedTitle;
@property (strong) NSString *feedLink;
@property (strong) NSImage *feedIcon;
@property (assign) BOOL cancelled;
@property (assign) NSInteger feedIconIdx;
@property (assign) NSInteger feedProcessCount;
@property (strong) NSMutableArray *feedIconLinks;


@end
