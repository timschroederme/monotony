//
//  NSData+Extensions.m
//  Monotony
//
//  Created by Tim Schröder on 15.11.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "NSData+Extensions.h"

@implementation NSData (Extensions)

// Source: http://www.chrisumbel.com/article/basic_authentication_iphone_cocoa_touch
static char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

-(NSString *)encode
{
    size_t encodedLength = (4 * (([self length] / 3) + (1 - (3 - ([self length] % 3)) / 3))) + 1;
    char *outputBuffer = malloc(encodedLength);
    char *inputBuffer = (char *)[self bytes];
    
    NSInteger i;
    NSInteger j = 0;
    NSInteger remain;
    
    for(i = 0; i < [self length]; i += 3) {
        remain = [self length] - i;
        
        outputBuffer[j++] = alphabet[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = alphabet[((inputBuffer[i] & 0x03) << 4) |
                                     ((remain > 1) ? ((inputBuffer[i + 1] & 0xF0) >> 4): 0)];
        
        if(remain > 1)
            outputBuffer[j++] = alphabet[((inputBuffer[i + 1] & 0x0F) << 2)
                                         | ((remain > 2) ? ((inputBuffer[i + 2] & 0xC0) >> 6) : 0)];
        else
            outputBuffer[j++] = '=';
        
        if(remain > 2)
            outputBuffer[j++] = alphabet[inputBuffer[i + 2] & 0x3F];
        else
            outputBuffer[j++] = '=';
    }
    
    outputBuffer[j] = 0;
    NSString *result = [NSString stringWithCString:outputBuffer encoding:NSASCIIStringEncoding];
    free(outputBuffer);
    
    return result;
}

@end
