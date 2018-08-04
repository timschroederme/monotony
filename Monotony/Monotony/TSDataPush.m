//
//  TSDataPush.m
//  Monotony
//
//  Created by Tim Schröder on 22.10.14.
//  Copyright (c) 2014 Tim Schröder. All rights reserved.
//

#import "TSDataPush.h"

@implementation TSDataPush


-(void) pushNotificationWithTitle:(NSString*)caption
{
    NSUserDefaults *sharedData = [[NSUserDefaults alloc] initWithSuiteName:@"GAW7W6LTYG.MonotonyAppSuite"];
    NSArray *array = (NSMutableArray*)[sharedData arrayForKey:@"news"];
    NSMutableArray *latestNews;
    if (array) {
        latestNews = [NSMutableArray arrayWithArray:array];
    } else {
        latestNews = [NSMutableArray arrayWithCapacity:3];
    }
    if ([latestNews count] == 3) {
        [latestNews removeObjectAtIndex:0];
    }
    [latestNews addObject:caption];
    [sharedData setObject:latestNews forKey:@"news"];
    [sharedData synchronize];
}

@end
