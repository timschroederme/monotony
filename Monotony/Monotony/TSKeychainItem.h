//
//  TSKeychainItem.h
//  Monotony
//
//  Created by Tim Schröder on 20.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSKeychainItem : NSObject
/*
{
    SecKeychainItemRef _item;
    NSString *_server;
    NSString *_path;
    NSString *_account;
    NSInteger _port;
    SecProtocolType _protocol;
    NSError *_error;
}

+ (TSKeychainItem *) keychainItemForServer:(NSString*)serverName
                                  withPath:(NSString*)path
                           withAccountName:(NSString*)accountName
                                  withPort:(NSInteger)thePort
                       withSecProtocolType:(SecProtocolType)theProtocol
                                     error:(NSError**)error;
+ (TSKeychainItem *) addKeychainItemForServer:(NSString*)serverName
                                     withPath:(NSString*)path
                              withAccountName:(NSString*)accountName
                                     withPort:(NSInteger)thePort
                          withSecProtocolType:(SecProtocolType)theProtocol
                                     password:(NSString*)password
                                        error:(NSError**)error;
- (void)deleteItem;
- (void)setNewPath:(NSString *)newPathName;

@property (strong) NSString *server;
@property (strong) NSString *path;
@property (strong) NSString *account;
@property (assign) NSInteger port;
@property (assign) SecProtocolType protocol;
@property (strong) NSString *password;
@property (readonly) NSError *error;
 */

@end
