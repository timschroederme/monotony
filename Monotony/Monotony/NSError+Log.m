//
//  NSError+Log.m
//  Monotony
//
//  Created by Tim Schröder on 20.10.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "NSError+Log.h"

@implementation NSError (Log)

-(void)logForClass:(NSString*)className method:(NSString*)methodName;
{
#ifdef DEBUG
    NSLog (@"An error occured in %@:%@: %li %@ %@ %@", className, methodName, self.code, self.domain, self.localizedDescription, self.localizedFailureReason);
#endif
}

@end
