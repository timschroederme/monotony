//
//  NSError+Log.h
//  Monotony
//
//  Created by Tim Schröder on 20.10.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Log)

-(void)logForClass:(NSString*)className method:(NSString*)methodName;

@end
