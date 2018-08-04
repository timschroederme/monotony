//
//  TSSubscriptionViewController.m
//  Monotony
//
//  Created by Tim Schröder on 18.01.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSSubscriptionViewController.h"
#import "TSSubscriptionController.h"
#import <QuartzCore/CoreAnimation.h>
#import "NSURL+Extensions.h"

@implementation TSSubscriptionViewController

@synthesize subscriptionWindow, mainSubscriptionView, subscriptionStartView, subscriptionCheckView, subscriptionErrorView, subscriptionChooseView, progressIndicator, rssURL, addFeedButton, errorOKButton, errorDescription, chooseFeedArrayController, chooseTableView, chooseScrollView, chooseButton, chooseColumn, subscriptionController, subscribingInProgressCaption;

#pragma mark -
#pragma mark Subclassed Methods

-(void)awakeFromNib
{
    [self.mainSubscriptionView addSubview:self.subscriptionStartView];
    [self.mainSubscriptionView addSubview:self.subscriptionCheckView];
    [self.mainSubscriptionView addSubview:self.subscriptionErrorView];
    [self.mainSubscriptionView addSubview:self.subscriptionChooseView];
    [self.mainSubscriptionView addSubview:self.credentialsView];
    [self.mainSubscriptionView addSubview:self.credentialsErrorView];
    [self.mainSubscriptionView addSubview:self.importSuccessView];
    [self.progressIndicator setUsesThreadedAnimation:NO];
    self.animationInProgress = NO;
}


#pragma mark -
#pragma mark General Action Methods

// Called by TSSubscriptionController when importing Feeds
- (void) showBusyView
{
    [self.subscriptionCheckView setHidden:NO];
    [self.subscriptionErrorView setHidden:YES];
    [self.subscriptionChooseView setHidden:YES];
    [self.credentialsView setHidden:YES];
    [self.credentialsErrorView setHidden:YES];
    [self.subscriptionStartView setHidden:YES];
    [self.importSuccessView setHidden:YES];
    NSRect superRect = [[self.subscriptionCheckView superview] frame];
    [self.subscriptionCheckView setFrame:superRect];
    [self.progressIndicator startAnimation:self];
    
    // Sheet anzeigen
	[NSApp beginSheet: self.subscriptionWindow
	   modalForWindow: [[NSApplication sharedApplication] mainWindow]
		modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo: nil];
}

// Feed abonnieren
-(IBAction) showSubscriptionWindow:(id)sender // Wird von Main Window aufgerufen, wenn auf + Button geklickt wird
{
    [self showSubscriptionWindowWithURL:nil];
}

#pragma mark -
#pragma mark TextField Delegate Methods

// Schaltet OK-Button im Add-Feed-Dialog ein oder aus, je nachdem, ob Text im Eingabefeld ist
- (void)controlTextDidChange:(NSNotification *)aNotification
{
    if (![self.subscriptionStartView isHidden]) {
        if ([[self.rssURL stringValue]length]>0) {
            [self.addFeedButton setEnabled: YES];
        }
        else {
            [self.addFeedButton setEnabled: NO];
        }
    }
    if (![self.credentialsView isHidden]) {
        if (([[self.credentialsUsernameField stringValue] length] > 0)&&([[self.credentialsPasswordField stringValue] length] > 0)) {
            [self.credentialsOKButton setEnabled:YES];
        } else {
            [self.credentialsOKButton setEnabled:NO];
        }
    }
}


#pragma mark -
#pragma mark Wait Text Adaption Methods

-(void)setStandardSubscribingCaption
{
    [self.subscribingInProgressCaption setStringValue:@"Subscribing.."];
}

-(void)setCustomSubscribingCaption:(NSString*)caption
{
    [self.subscribingInProgressCaption setStringValue:caption];
}


#pragma mark -
#pragma mark Animation Methods

- (void) verticalSwitchToView:(NSView*)newView fromView:(NSView*)oldView downUp:(BOOL)downUp
{
    // Falls schon Animation läuft, die stoppen
    if (self.animationInProgress) {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.0];
        [NSAnimationContext endGrouping];
    }
    
    NSRect superRect = [[oldView superview] frame];
    NSRect newRectStart = superRect;
    NSRect oldRectEnd = superRect;
    
    if (downUp) {
        newRectStart.origin.y = superRect.origin.y - superRect.size.height;
        oldRectEnd.origin.y = superRect.origin.y + superRect.size.height;
    } else {
        newRectStart.origin.y = superRect.origin.y + superRect.size.height;
        oldRectEnd.origin.y = superRect.origin.y - superRect.size.height;
    }
    [newView setFrame:newRectStart];
    [newView setHidden:NO];
    
    [[NSAnimationContext currentContext] setCompletionHandler:^(void) {
        [self.animationOldView setHidden:YES];
        [self.animationOldView setFrame:self.animationOldSuperRect];
        self.animationInProgress = NO;
    }];
    
    self.animationInProgress = YES;
    self.animationOldView = oldView;
    self.animationOldSuperRect = superRect;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.2]; 
    CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [[NSAnimationContext currentContext] setTimingFunction:timing];
    [[newView animator] setFrame:superRect];
    [[oldView animator] setFrame:oldRectEnd];
    [NSAnimationContext endGrouping];
}


#pragma mark -
#pragma mark Public Methods

// Wird von AppDelegate aufgerufen
-(void) showSubscriptionWindowWithURL:(NSURL*)URL
{
    [self.chooseButton setKeyEquivalent:@""];
    [self.addFeedButton setKeyEquivalent:@"\r"];
    [self.errorOKButton setKeyEquivalent:@""];
    if (URL) {
        [self.rssURL setStringValue:[URL absoluteString]];
        [self.addFeedButton setEnabled:YES];
    } else {
        [self.rssURL setStringValue:@""];
        [self.addFeedButton setEnabled:NO];
    }
    [self.subscriptionWindow makeFirstResponder:rssURL];
    [self.subscriptionCheckView setHidden:YES];
    [self.subscriptionErrorView setHidden:YES];
    [self.subscriptionChooseView setHidden:YES];
    [self.credentialsView setHidden:YES];
    [self.credentialsErrorView setHidden:YES];
    [self.importSuccessView setHidden:YES];
    [self.subscriptionStartView setHidden:NO];
    NSRect superRect = [[self.subscriptionStartView superview] frame];
    [self.subscriptionStartView setFrame:superRect];
       
    // Sheet anzeigen
	[NSApp beginSheet: self.subscriptionWindow
	   modalForWindow: [[NSApplication sharedApplication] mainWindow]
		modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo: nil];
}

// Auswahl mehrerer möglicher Feeds anzeigen
- (void) showMultipleFeedsForSelection:(NSArray*)choices
{
    // TableView für Anzeige vorbereiten
    [self.chooseFeedArrayController removeObjects:[self.chooseFeedArrayController arrangedObjects]];
    [self.chooseFeedArrayController addObjects:choices];
    NSIndexSet *index = [NSIndexSet indexSetWithIndex:0];
    [self.chooseTableView selectRowIndexes:index byExtendingSelection:NO]; // Erste Zeile auswählen
    [self.addFeedButton setKeyEquivalent:@""];
    [self.chooseButton setKeyEquivalent:@"\r"];
    
    // Breite der Tabellenspalte festlegen
    NSInteger i;
    float maxWidth = 0.0;
    for (i=0;i<[self.chooseTableView numberOfRows];i++) {
        NSCell *cell = [self.chooseColumn dataCellForRow:i];
        NSDictionary *dict = [choices objectAtIndex:i];
        NSString *aString = [NSString stringWithFormat:@"%@ (%@)", [dict objectForKey:@"title"], [dict objectForKey:@"urlString"]];
        NSFont *font = [cell font];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        NSSize extent = [aString sizeWithAttributes:attributes];
        if (extent.width > maxWidth) maxWidth = extent.width;
    }
    maxWidth = maxWidth + 2.0;
    [self.chooseColumn setWidth:maxWidth];
    
    // Scrollposition auf 0.0 setzen
    [[self.chooseScrollView contentView] setBoundsOrigin:NSMakePoint(0.0, 0.0)];
    
    // Anzeigen
    [self.progressIndicator stopAnimation:self];
    [self.subscriptionWindow makeFirstResponder:self.chooseScrollView];
    [self verticalSwitchToView:self.subscriptionChooseView fromView:self.subscriptionCheckView downUp:YES];
}

-(void)showErrorMessage:(NSError*)error
{
    // Nächstes Sheet-Element
    [self.progressIndicator stopAnimation:self];
    [self.errorOKButton setKeyEquivalent:@"\r"];
    [self.chooseButton setKeyEquivalent:@""];
    [self.addFeedButton setKeyEquivalent:@""];
    [self.subscriptionWindow makeFirstResponder:self.errorOKButton];
    if (error) {
        [self.errorDescription setStringValue:[error localizedDescription]];
    } else {
        [self.errorDescription setStringValue:@"Failed to subscribe for unknown reasons"];
    }
    [self verticalSwitchToView:self.subscriptionErrorView fromView:self.subscriptionCheckView downUp:YES];
}

- (IBAction)subscribe:(id)sender
{
    // Nächstes Sheet-Element
    [self.addFeedButton setEnabled:NO];
    [self setStandardSubscribingCaption];
    [self verticalSwitchToView:self.subscriptionCheckView fromView:self.subscriptionStartView downUp:YES];
    [self.progressIndicator startAnimation:self];

    // Feed subscriben
    NSURL *feedURL = [[NSURL URLWithString:[rssURL stringValue]] addScheme];
    [self.subscriptionController startSubscriptionWithURL:feedURL];
}

- (IBAction)cancelSubscription:(id)sender
{
    [self.progressIndicator stopAnimation:self];
	[NSApp endSheet:self.subscriptionWindow returnCode: NSCancelButton];
    [self.subscriptionController cancelSubscription];
}

- (IBAction) feedChosenFromSelection:(id)sender
{
    NSUInteger sel = [self.chooseFeedArrayController selectionIndex];
    [self.progressIndicator startAnimation:self];
    [self setStandardSubscribingCaption];
    [self verticalSwitchToView:self.subscriptionCheckView fromView:self.subscriptionChooseView downUp:YES];
    NSURL *URL = [NSURL URLWithString:[[[self.chooseFeedArrayController arrangedObjects] objectAtIndex:sel] objectForKey:@"urlString"]];
    [self.subscriptionController startSubscriptionWithURL:URL];
}

- (void) showImportSuccessInfo:(NSInteger)importCount
{
    NSString *informativeText = [NSString stringWithFormat:@"%li Feed URLs successfully imported.", importCount];
    [self.importSuccessfulCaption setStringValue:informativeText];
    [self verticalSwitchToView:self.importSuccessView fromView:self.subscriptionCheckView downUp:YES];
}


#pragma mark -
#pragma mark Credentials Methods


// Passworteingabe anzeigen
-(void) askForCredentials
{
    [self.progressIndicator stopAnimation:self];
    [self.subscriptionWindow makeFirstResponder:self.credentialsUsernameField];
    [self.addFeedButton setKeyEquivalent:@""];
    [self.credentialsOKButton setKeyEquivalent:@"\r"];
    [self.credentialsOKButton setEnabled:NO];
    [self.credentialsUsernameField setStringValue:@""];
    [self.credentialsPasswordField setStringValue:@""];
    [self verticalSwitchToView:self.credentialsView fromView:self.subscriptionCheckView downUp:YES];
}

// Falsche Daten eingegeben, Fehlermeldung anzeigen
-(void) wrongCredentials
{
    [self.progressIndicator stopAnimation:self];
    [self.credentialsOKButton setKeyEquivalent:@""];
    [self.credentialsErrorOKButton setKeyEquivalent:@"\r"];
    [self.subscriptionWindow makeFirstResponder:self.credentialsErrorOKButton];
    [self verticalSwitchToView:self.credentialsErrorView fromView:self.subscriptionCheckView downUp:YES];
}

- (IBAction)checkCredentials:(id)sender
{
    // Nächstes Sheet-Element
    [self setStandardSubscribingCaption];
    [self verticalSwitchToView:subscriptionCheckView fromView:self.credentialsView downUp:YES];
    [self.progressIndicator startAnimation:self];
    //[self.subscriptionController setUsername:[self.credentialsUsernameField stringValue] password:[self.credentialsPasswordField stringValue]];
    NSURL *feedURL = [[NSURL URLWithString:[rssURL stringValue]] addScheme];
    [self.subscriptionController startSubscriptionWithURL:feedURL];

    // Credentials checken
    // NSURL *feedURL = [[NSURL URLWithString:[rssURL stringValue]] addScheme];
    // NSString *username = [self.credentialsUsernameField stringValue];
    // NSString *password = [self.credentialsPasswordField stringValue];
    // [[NSApp delegate] enteredCredentialsWithURL:feedURL username:username password:password];
}

- (IBAction) tryAgainCredentials:(id)sender
{
    [self.subscriptionWindow makeFirstResponder:self.credentialsUsernameField];
    [self.credentialsErrorOKButton setKeyEquivalent:@""];
    [self.credentialsOKButton setKeyEquivalent:@"\r"];
    [self.credentialsOKButton setEnabled:NO];
    [self.credentialsUsernameField setStringValue:@""];
    [self.credentialsPasswordField setStringValue:@""];
    [self verticalSwitchToView:self.credentialsView fromView:self.credentialsErrorView downUp:YES];
}


#pragma mark -
#pragma mark Sheet Methods

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[self.subscriptionWindow orderOut:nil];
}


@end
