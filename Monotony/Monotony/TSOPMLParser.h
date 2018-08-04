//
//  TSOPMLParser.h
//  Monotony
//
//  Created by Tim Schröder on 01.01.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSOPMLParser : NSObject

-(BOOL)exportFeedURLs:(NSArray*)feeds toLocation:(NSURL*)URL;
-(NSArray*)importFeedsFromLocation:(NSURL*)URL;

@end
