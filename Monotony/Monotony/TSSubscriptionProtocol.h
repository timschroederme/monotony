//
//  TSSubscriptionProtocol.h
//  Monotony
//
//  Created by Tim Schröder on 02.01.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSSubscriptionProtocol <NSObject>

@required

-(void) askForCredentials;
-(void) subscriptionFailedWithError:(NSError*)error;
-(void) chooseFromFeeds:(NSArray*)feeds;
-(void) subscriptionSucceededWithURL:(NSURL*)feedURL
                                icon:(NSImage*)feedIcon
                               title:(NSString*)feedTitle;

@end
