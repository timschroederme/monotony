//
//  TSChooseFeedValueTransformer.m
//  Monotony
//
//  Created by Tim Schröder on 27.10.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSChooseFeedValueTransformer.h"

@implementation TSChooseFeedValueTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if (!value) return nil;
    NSString *title = [value objectForKey:@"title"];
    NSString *urlString = [value objectForKey:@"urlString"];
    return ([NSString stringWithFormat:@"%@ (%@)", title, urlString]);
}

@end