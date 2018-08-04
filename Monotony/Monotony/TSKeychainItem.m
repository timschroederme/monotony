//
//  TSKeychainItem.m
//  Monotony
//
//  Created by Tim Schröder on 20.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSKeychainItem.h"

@interface TSKeychainItem (Private)

/*
- (TSKeychainItem *)initWithKeychainItem:(SecKeychainItemRef)item
                                    path:(NSString*)pathName
                                  server:(NSString*)serverName
                                 account:(NSString*)accountName
                                    port:(NSInteger)thePort
                         secProtocolType:(SecProtocolType)theProtocol;

@end

@implementation TSKeychainItem

@synthesize server = _server;
@synthesize path = _path;
@synthesize account = _account;
@synthesize port = _port;
@synthesize protocol = _protocol;
@synthesize error = _error;

- (TSKeychainItem *)initWithKeychainItem:(SecKeychainItemRef)item
                                    path:(NSString*)pathName
                                  server:(NSString*)serverName
                                 account:(NSString*)accountName
                                    port:(NSInteger)thePort
                         secProtocolType:(SecProtocolType)theProtocol
{
    if (self = [super init]) {
        _item = item;
        _server = [serverName copy];
        _path = [pathName copy];
        _account = [accountName copy];
        _port = thePort;
        _protocol = theProtocol;
        
    }
    return self;
}

- (void) finalize
{
    if (_item) CFRelease(_item);
    [super finalize];
}


+ (TSKeychainItem *) keychainItemForServer:(NSString*)serverName
                                  withPath:(NSString*)pathName
                           withAccountName:(NSString*)accountName
                                  withPort:(NSInteger)thePort
                       withSecProtocolType:(SecProtocolType)theProtocol
                                     error:(NSError**)error
{
    //NSAssert (serverName && pathName && accountName && thePort && theProtocol, @"Keychain: Missing arguments!");
    if (error) *error = nil;
    TSKeychainItem *keychainItem = nil;
    SecKeychainItemRef item = NULL;
    const char *theServerName = [serverName UTF8String];
    const char *theAccountName = [accountName UTF8String];
    const char *thePathName = [pathName UTF8String];
    
    OSStatus err = SecKeychainFindInternetPassword(nil,
                                                   (UInt32)strlen(theServerName),
                                                   theServerName,
                                                   0,
                                                   NULL,
                                                   (UInt32)strlen(theAccountName),
                                                   theAccountName,
                                                   (UInt32)strlen(thePathName),
                                                   thePathName,
                                                   (UInt16)thePort,
                                                   theProtocol,
                                                   kSecAuthenticationTypeDefault,
                                                   NULL,
                                                   NULL,
                                                   &item);
    
    if (err == noErr) {
        keychainItem = [[TSKeychainItem alloc] initWithKeychainItem:item
                                                               path:pathName
                                                             server:serverName
                                                            account:accountName
                                                               port:thePort
                                                    secProtocolType:theProtocol];
    } else {
        if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                                code:err
                                            userInfo:nil];
    }
    return keychainItem;
}

+ (TSKeychainItem *) addKeychainItemForServer:(NSString*)serverName
                                     withPath:(NSString*)pathName
                              withAccountName:(NSString*)accountName
                                     withPort:(NSInteger)thePort
                          withSecProtocolType:(SecProtocolType)theProtocol
                                     password:(NSString*)password
                                        error:(NSError**)error
{
    //NSAssert (serverName && pathName && accountName && thePort && theProtocol && password, @"Keychain: Missing arguments!");
    if (error) *error = nil;
    TSKeychainItem *keychainItem = nil;
    SecKeychainItemRef item = NULL;
    const char *theServerName = [serverName UTF8String];
    const char *theAccountName = [accountName UTF8String];
    const char *thePathName = [pathName UTF8String];
    const char *thePassword = [password UTF8String];
    
    
    OSStatus err = SecKeychainAddInternetPassword(NULL,
                                                  (UInt32)strlen(theServerName),
                                                  theServerName,
                                                  0,
                                                  NULL,
                                                  (UInt32)strlen(theAccountName),
                                                  theAccountName,
                                                  (UInt32)strlen(thePathName),
                                                  thePathName,
                                                  (UInt16)thePort,
                                                  theProtocol,
                                                  kSecAuthenticationTypeDefault,
                                                  (UInt32)strlen(thePassword),
                                                  thePassword,
                                                  &item);
    
    if (err == noErr) {
        keychainItem = [[TSKeychainItem alloc] initWithKeychainItem:item
                                                               path:pathName
                                                             server:serverName
                                                            account:accountName
                                                               port:thePort
                                                    secProtocolType:theProtocol];
    } else {
        if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                                code:err
                                            userInfo:nil];
    }
    return keychainItem;
}

-(void)setPassword:(NSString *)password
{
    _error = nil;
    const char *newPassword = [password UTF8String];
    OSStatus err = SecKeychainItemModifyAttributesAndData(_item, NULL, (UInt32)strlen(newPassword), newPassword);
    if (err != noErr) _error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                                   code:err
                                               userInfo:nil];
}

-(NSString*)password
{
    _error = nil;
    const char *theServerName = [_server UTF8String];
    const char *theAccountName = [_account UTF8String];
    const char *thePathName = [_path UTF8String];
    UInt32 passwordLength = 0;
    char *password = NULL;
    NSString *passwordString = nil;
    
    OSStatus err = SecKeychainFindInternetPassword(nil,
                                                   (UInt32)strlen(theServerName),
                                                   theServerName,
                                                   0,
                                                   NULL,
                                                   (UInt32)strlen(theAccountName),
                                                   theAccountName,
                                                   (UInt32)strlen(thePathName),
                                                   thePathName,
                                                   (UInt16)_port,
                                                   _protocol,
                                                   kSecAuthenticationTypeDefault,
                                                   &passwordLength,
                                                   (void**)&password,
                                                   NULL);
    if (err == noErr) {
        passwordString = [[NSString alloc] initWithBytes:password
                                                  length:passwordLength
                                                encoding:NSUTF8StringEncoding];
        SecKeychainItemFreeContent(NULL,password);
    } else {
        _error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                     code:err
                                 userInfo:nil];
    }
    return (passwordString);
}

-(void)deleteItem
{
    SecKeychainItemDelete(_item);
}

-(void)setNewPath:(NSString *)newPathName
{
    _error = nil;
    if (![_path isEqual:newPathName]) {
        const char *newPath = [newPathName UTF8String];
        SecKeychainAttribute attr;
        attr.tag = kSecPathItemAttr;
        attr.data = (void*)newPath;
        attr.length=(UInt32)strlen(newPath);
        SecKeychainAttributeList list;
        list.count = 1;
        list.attr = &attr;
        
        OSStatus err = SecKeychainItemModifyAttributesAndData(_item, &list, 0, NULL);
        if (err == noErr) {
            _path = [newPathName copy];
        } else {
            _error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                         code:err
                                     userInfo:nil];
        }
    }
}


-(void)setServer:(NSString *)serverName
{
    _error = nil;
    if (![_server isEqual:serverName]) {
        // Hier werden zwei Attribute gesetzt - Server und Label, letzteres für die Anzeige in der Schlüsselbundverwaltung
        const char *newServerName = [serverName UTF8String];
        SecKeychainAttribute attr[2];
        attr[0].tag = kSecServerItemAttr;
        attr[1].tag = kSecLabelItemAttr;
        attr[0].data = (void*)newServerName;
        attr[0].length=(UInt32)strlen(newServerName);
        attr[1].data = (void*)newServerName;
        attr[1].length=(UInt32)strlen(newServerName);
        SecKeychainAttributeList list = {2, attr};
        
        OSStatus err = SecKeychainItemModifyAttributesAndData(_item, &list, 0, NULL);
        if (err == noErr) {
            _server = [serverName copy];
        } else {
            _error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                         code:err
                                     userInfo:nil];
        }
    }
}

-(void)setAccount:(NSString *)accountName
{
    _error = nil;
    if (![_account isEqual:accountName]) {
        const char *newAccount = [accountName UTF8String];
        SecKeychainAttribute attr;
        attr.tag = kSecAccountItemAttr;
        attr.data = (void*)newAccount;
        attr.length=(UInt32)strlen(newAccount);
        SecKeychainAttributeList list;
        list.count = 1;
        list.attr = &attr;
        
        OSStatus err = SecKeychainItemModifyAttributesAndData(_item, &list, 0, NULL);
        if (err == noErr) {
            _account = [accountName copy];
        } else {
            _error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                         code:err
                                     userInfo:nil];
        }
    }
}

-(void)setPort:(NSInteger)port
{
    _error = nil;
    if (!(_port==port)) {
        SecKeychainAttribute attr;
        attr.tag = kSecPortItemAttr;
        attr.data = &port;
        attr.length= sizeof(UInt16);
        SecKeychainAttributeList list;
        list.count = 1;
        list.attr = &attr;
        
        OSStatus err = SecKeychainItemModifyAttributesAndData(_item, &list, 0, NULL);
        if (err == noErr) {
            _port = port;
        } else {
            _error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                         code:err
                                     userInfo:nil];
        }
    }
}

-(void)setProtocol:(SecProtocolType)protocol
{
    _error = nil;
    if (!(_protocol==protocol)) {
        SecKeychainAttribute attr;
        attr.tag = kSecProtocolItemAttr;
        attr.data = &protocol;
        attr.length= sizeof(FourCharCode);
        SecKeychainAttributeList list;
        list.count = 1;
        list.attr = &attr;
        
        OSStatus err = SecKeychainItemModifyAttributesAndData(_item, &list, 0, NULL);
        if (err == noErr) {
            _protocol = protocol;
        } else {
            _error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                         code:err
                                     userInfo:nil];
        }
    }
}
*/


@end
