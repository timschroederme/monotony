//
//  TSMainViewController.m
//  Monotony
//
//  Created by Tim Schröder on 25.10.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSMainViewController.h"
#import "TSDefaultsController.h"
#import "TSStatusItemController.h"
#import "TSLaunchAtLoginController.h"
#import "TSNotificationController.h"
#import "TSTableRowView.h"
#import "TSFeedController.h"
#import "TSSubscriptionController.h"
#import "TSOPMLParser.h"

@implementation TSMainViewController

BOOL initializing = YES;

@synthesize window, runInvisibleButton, launchAtLoginButton, useGrowlButton, useGrowlLabel, feedController, tableView, subscriptionController;


#pragma mark -
#pragma mark Overriden Methods

-(void)awakeFromNib
{
    if (!initializing) return;
    initializing = NO;
    // Register for Window Notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:NULL];
    
    // RunInvisible umsetzen
    BOOL runInvisible = [[TSDefaultsController sharedController] runInvisible];
    [[TSStatusItemController sharedController] setAction:@selector(showWindow)];
    [[TSStatusItemController sharedController] setTarget:self];
    if (runInvisible) {
        [self.runInvisibleButton setSelectedSegment:0];
    } else {
        [[TSStatusItemController sharedController] showStatusIcon];
    }
    
    // LaunchAtLogin umsetzen
    BOOL shouldLaunchAtLogin = [[TSDefaultsController sharedController] launchAtLogin];
    if (shouldLaunchAtLogin) [self.launchAtLoginButton setSelectedSegment:0];
    
    // UseGrowl-Button umsetzen
    BOOL useGrowl = [[TSDefaultsController sharedController] useGrowl];
    if (useGrowl) [self.useGrowlButton setSelectedSegment:0];
}


#pragma mark -
#pragma mark Action Methods

// Called by AppDelegate
-(void)showWindow
{
    [NSApp activateIgnoringOtherApps:YES];
    [self.window makeKeyAndOrderFront:self];
}

// Called by AppDelegate
-(void) showSubscriptionWindowWithURL:(NSURL*)URL
{
    [self.subscriptionController showSubscriptionWindowWithURL:URL];
}

// Feed löschen
-(IBAction) unsubscribeFromFeed:(id)sender
{
    [self.feedController unsubscribeFromSelectedFeed];
}

// Feeds laden
-(void)loadFeeds
{
    [self.feedController loadFeeds];
}

// Import Feeds from an OPML file
-(IBAction)importFeeds:(id)sender
{
    // Open Panel vorbereiten
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"xml", @"XML", nil]];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowsOtherFileTypes:YES];
    [openPanel setMessage:@"Import Feed URLs from an OPML XML file"];
    [openPanel setPrompt:@"Import"];
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger returnCode){
        
        if( returnCode == NSFileHandlingPanelCancelButton ) {
            return;
        }
        
        // Gewählte Datei ermitteln
        NSArray *urls = [openPanel URLs];
        if( urls != nil && [urls count] == 1 ) {
            NSURL *url = [urls objectAtIndex:0];

            // Feed-URLs importieren
            TSOPMLParser *opmlParser = [[TSOPMLParser alloc] init];
            NSArray *feedsToImport = [opmlParser importFeedsFromLocation:url];
            if (feedsToImport) {
                [self.subscriptionController importURLs:feedsToImport];
            } else {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Import failed"
                                                 defaultButton:@"OK"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"An error occurred."];
                [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
            }
        }
    }];
}

// Exports Feeds as OPML file
-(IBAction)exportFeeds:(id)sender
{
    // Save Panel vorbereiten
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"xml", @"XML", nil]];
    [savePanel setAllowsOtherFileTypes:YES];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setCanSelectHiddenExtension:YES];
    [savePanel setMessage:@"Export Feed URLs as OPML XML file"];
    [savePanel setPrompt:@"Export"];
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger returnCode){
        
        if( returnCode == NSFileHandlingPanelCancelButton ) {
            return;
        }
        
        // Gewählte Datei ermitteln
        NSURL *url = [savePanel URL];
        BOOL success;
        if (url) {
            
            // Feed-URLs exportieren
            TSOPMLParser *opmlParser = [[TSOPMLParser alloc] init];
            success = [opmlParser exportFeedURLs:[self.feedController allFeeds]
                            toLocation:url];
        } else {
            success = NO;
        }
        NSString *messageText;
        NSString *informativeText;
        if (success) {
            messageText = @"Export succeded";
            informativeText = [NSString stringWithFormat:@"%li Feed URLs successfully exported.", [[self.feedController allFeeds]count]];
        } else {
            messageText = @"Export failed";
            informativeText = @"An error occurred.";
        }
        NSAlert *alert = [NSAlert alertWithMessageText:messageText
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"%@", informativeText];
        [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
    }];
}


#pragma mark -
#pragma mark Launch At Login Action Method

-(IBAction)toggleLaunchAtLogin:(id)sender
{
    NSInteger clickedSegment = [sender selectedSegment];
    if (clickedSegment == 0) { // ON
        if ([[TSDefaultsController sharedController] launchAtLogin]) return;
        [[TSDefaultsController sharedController] setLaunchAtLogin:YES];
        [[TSLaunchAtLoginController sharedController] turnOnLaunchAtLogin];
    }
    if (clickedSegment == 1) { // OFF
        if (![[TSDefaultsController sharedController] launchAtLogin]) return;
        [[TSDefaultsController sharedController] setLaunchAtLogin:NO];
        [[TSLaunchAtLoginController sharedController] turnOffLaunchAtLogin];
    }
}


#pragma mark -
#pragma mark Toggle Use Growl

- (IBAction) toggleUseGrowl:(id)sender
{
    NSInteger clickedSegment = [sender selectedSegment];
    if (clickedSegment == 0) { // ON
        if ([[TSDefaultsController sharedController] useGrowl]) return;
        [[TSDefaultsController sharedController] setUseGrowl:YES];
    }
    if (clickedSegment == 1) { // OFF
        if (![[TSDefaultsController sharedController] useGrowl]) return;
        [[TSDefaultsController sharedController] setUseGrowl:NO];
    }
}


#pragma mark -
#pragma mark Run Invisible Action Methods

-(IBAction)toggleRunInvisible:(id)sender
{
    NSInteger clickedSegment = [sender selectedSegment];
    if (clickedSegment == 0) { // ON
        if ([[TSDefaultsController sharedController] runInvisible]) return;
        
        // Warnung anzeigen
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Enabling this option will let Monotony run in the background."];
        [alert setInformativeText:@"To access the preferences window, open Monotony in Launchpad or in Finder."];
        [alert beginSheetModalForWindow:[self window]
                          modalDelegate:self
                         didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                            contextInfo:nil];
    }
    if (clickedSegment == 1) { // OFF
        if (![[TSDefaultsController sharedController] runInvisible]) return;
        [[TSDefaultsController sharedController] setRunInvisible:NO];
        [[TSStatusItemController sharedController] showStatusIcon];
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertFirstButtonReturn) {
        [[TSDefaultsController sharedController] setRunInvisible:YES];
        [[TSStatusItemController sharedController] hideStatusIcon];
    } else { // Cancel
        [self.runInvisibleButton setSelectedSegment:1];
    }
}


#pragma mark -
#pragma mark NSWindow Notification Methods

// Move focus to another app if the app's main window is closed.
-(void)windowWillClose:(NSNotification*)aNotification
{
    if ([[aNotification object] isEqualTo:self.window]) { // Ist das Fenster, das geschlossen wird, das Hauptfenster?
        [NSApp hide:self];
    }
}


#pragma mark -
#pragma mark TableView Methods

-(void)scrollTableToTop
{
    [self.tableView scrollRowToVisible:0];
}

-(void)scrollTableToRow:(NSInteger)row
{
    [self.tableView scrollRowToVisible:row];
}


#pragma mark -
#pragma mark NSTableView Delegate

// Um Custom NSTableRowView subclass einzuführen
-(NSTableRowView *)tableView:(NSTableView *)tv
               rowViewForRow:(NSInteger)row
{
     TSTableRowView *result = [tv makeViewWithIdentifier:@"myrowview" owner:self];
     if (result == nil) {
         result = [[TSTableRowView alloc] initWithFrame:NSZeroRect];
         result.identifier = @"myrowview";
     }
    return result;
}


// Sets tooltip information
- (NSView *)tableView:(NSTableView *)tv
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    NSTableCellView *result;
    result = [tv makeViewWithIdentifier:@"mycellview" owner:self];
    if (result == nil) {
        result = [[NSTableCellView alloc] initWithFrame:NSZeroRect];
        result.identifier = @"mycellview";
    }
    [result setToolTip:[[self.feedController URLForTableRow:row] absoluteString]];
    return result;
}


#pragma mark -
#pragma mark NSTextField Delegate

// Wont't be called if auto-rearrange is turned on in the array controller
- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    NSInteger selectionIndex = [self.feedController selectionIndex];
    if (selectionIndex == NSNotFound) return;
    [self.feedController saveSelectedFeedAndRearrange];
    [self.tableView scrollRowToVisible:selectionIndex];
}


#pragma mark -
#pragma mark NSMenu Methods

- (IBAction)copyLink:(id)sender
{
    // Retrieve URL
    NSInteger row = [self.tableView clickedRow];
    if (row == -1) return;
    NSURL *URL = [self.feedController URLForTableRow:row];
    
    // Copy URL to Pasteboard
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSArray *objectsToCopy = [NSArray arrayWithObject:URL];
    [pasteboard writeObjects:objectsToCopy];
}


@end
