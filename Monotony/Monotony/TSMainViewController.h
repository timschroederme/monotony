//
//  TSMainViewController.h
//  Monotony
//
//  Created by Tim Schröder on 25.10.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The TSMainViewController class manages key aspects of the main window (with the exception of the table view's contents, which is managed with bindings). The TSMainController class instance holds an instance variable of TSMainViewController. 
 
 @discussion The class has only one public method, -showWindow. All other methods are private methods.
 */

@class TSFeedController, TSSubscriptionController;

@interface TSMainViewController : NSObject <NSTableViewDelegate>

/** @name Show Main Window */

/** Display the app's main window. Is called by the TSMainController class.*/
- (void) showWindow; 

-(void) showSubscriptionWindowWithURL:(NSURL*)URL; // Called by AppDelegate

-(IBAction) unsubscribeFromFeed:(id)sender;

-(IBAction)importFeeds:(id)sender;
-(IBAction)exportFeeds:(id)sender;

-(void)loadFeeds;

/** @name Overriden */

/** The overriden method registers the class instance for several user interface related notifications and sets the state of the main window's buttons according to the settings stored in the app's user defaults.
 */
- (void) awakeFromNib;


/** @name Toggle Launch at Login Action */

/** The method is called by the XIB file when the user toggles the Launch-At-Login-Button. Method shouldn't be called from code.
 @param sender not important.
 */
- (IBAction) toggleLaunchAtLogin:(id)sender;

/** @name Use Growl Action */

/** This method is called by the XIB file when the user toggles the use Growl button. Method shouldn't be called from code and does only make sense when running on OS X 10.8.
 @param sender not important.
 */
- (IBAction) toggleUseGrowl:(id)sender;


/** @name Toggle Run Invisible */

/** The method is called by the XIB file when the user toggles the Run-Invisible-Button. If run invisible should be turned on, the method displas an alert to let the user confirm his choice. Method shouldn't be called from code. 
 @param sender not important.
 */
- (IBAction) toggleRunInvisible:(id)sender;

/** Called by the alert displayed by the toggleRunInvisible: method. If the user confirmed that he wants to run invisible, this method does it by hiding the status bar icon and storing the new setting to the user defaults. Method shouldn't be called directly.
 @param alert not important.
 @param returnCode not important.
 @param contextInfo not important.
 */
- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;


/** @name Window Notifications */

/** Will be called if any window of the app is closed. If the main window is closed, the method returns focus to the next app in the focus queue. Notification method, shouldn't be called directly.
 @param aNotification not important.
 */
- (void) windowWillClose:(NSNotification*)aNotification;


-(void)scrollTableToTop;
-(void)scrollTableToRow:(NSInteger)row;

/** @name Tableview Delegate */

/** This method is responsible for returning the custom TSTableRowView instead of the normal NSTableRowView. Delegate method, shouldn't be called directly.
 @param tv not important.
 @param row not important.
 */
-(NSTableRowView *)tableView:(NSTableView *)tv
               rowViewForRow:(NSInteger)row;

/** Sets the tooltip of the table column to the URL of the feed it represents. Delegate method, shouldn't be called directly.

 @param tv not important.
 @param tableColumn not important.
 @param row not important.
 */
- (NSView *)tableView:(NSTableView *)tv
viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row;


/** @name Textfield Delegate */

/** Is called after the user finished editing a feed title in the table view. The method saves the changed feed to HDD, sorts the table view and, if necessary, scrolls the table view so that the selected, re-ordered selected row remains visible. Delegate method, shouldn't be called directly.
 
 @param aNotification not important.
 
 @warning This delegate method won't be called if the array controller's auto-rearrange property is enabled.
 */

- (void)controlTextDidEndEditing:(NSNotification *)aNotification;

/** @name NSMenu Methods */

- (IBAction)copyLink:(id)sender;

/** Reference to the app's main window.*/
@property (assign) IBOutlet NSWindow* window;

/** Reference to the run invisible toggle button.*/
@property (assign) IBOutlet NSSegmentedControl *runInvisibleButton;

/** Reference to the launch at login toggle button.*/
@property (assign) IBOutlet NSSegmentedControl *launchAtLoginButton;

/** Reference to the use Growl button. */
@property (assign) IBOutlet NSSegmentedControl *useGrowlButton;

/** Reference to use growl description. */
@property (assign) IBOutlet NSTextField *useGrowlLabel;

/** Reference to the table view's content array controller.*/
//@property (assign) IBOutlet NSArrayController *feedController;

/** Reference to the main window's table view.*/
@property (assign) IBOutlet NSTableView *tableView;

@property (assign) IBOutlet TSFeedController *feedController;

@property (assign) IBOutlet TSSubscriptionController *subscriptionController;


@end
