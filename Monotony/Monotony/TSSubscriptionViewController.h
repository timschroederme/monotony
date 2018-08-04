//
//  TSSubscriptionViewController.h
//  Monotony
//
//  Created by Tim Schröder on 18.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSSubscriptionController;


@interface TSSubscriptionViewController : NSObject <NSTextFieldDelegate>

- (void) showSubscriptionWindowWithURL:(NSURL*)URL;
- (void) showMultipleFeedsForSelection:(NSArray*)choices;
- (void) showErrorMessage:(NSError*)error;
- (void) showBusyView;
- (IBAction) showSubscriptionWindow:(id)sender;
- (IBAction) subscribe:(id)sender;
- (IBAction) cancelSubscription: (id)sender;
-(void)setCustomSubscribingCaption:(NSString*)caption;
- (IBAction) feedChosenFromSelection:(id)sender;
- (void) askForCredentials;
- (void) showImportSuccessInfo:(NSInteger)importCount;

@property (assign) IBOutlet NSWindow *subscriptionWindow;
@property (assign) IBOutlet NSView *mainSubscriptionView;
@property (assign) IBOutlet NSView *subscriptionStartView;
@property (assign) IBOutlet NSView *subscriptionCheckView;
@property (assign) IBOutlet NSView *subscriptionErrorView;
@property (assign) IBOutlet NSView *subscriptionChooseView;
@property (assign) IBOutlet NSTextField *subscribingInProgressCaption;
@property (assign) IBOutlet NSView *credentialsView;
@property (assign) IBOutlet NSView *credentialsErrorView;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSTextField *rssURL;
@property (assign) IBOutlet NSButton *addFeedButton;
@property (assign) IBOutlet NSButton *errorOKButton;
@property (assign) IBOutlet NSTextField *errorDescription;
@property (assign) IBOutlet NSArrayController *chooseFeedArrayController;
@property (assign) IBOutlet NSTableView *chooseTableView;
@property (assign) IBOutlet NSScrollView *chooseScrollView;
@property (assign) IBOutlet NSButton *chooseButton;
@property (assign) IBOutlet NSTableColumn *chooseColumn;
@property (assign) IBOutlet NSButton *credentialsOKButton;
@property (assign) IBOutlet NSTextField *credentialsUsernameField;
@property (assign) IBOutlet NSTextField *credentialsPasswordField;
@property (assign) IBOutlet NSButton *credentialsErrorOKButton;
@property (assign) IBOutlet TSSubscriptionController *subscriptionController;
@property (assign) BOOL animationInProgress;
@property (strong) NSView *animationOldView;
@property (assign) NSRect animationOldSuperRect;
@property (assign) IBOutlet NSTextField *importSuccessfulCaption;
@property (assign) IBOutlet NSView *importSuccessView;


@end
