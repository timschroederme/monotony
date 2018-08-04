//
//  TSTableRowView.m
//  Monotony
//
//  Created by Tim Schröder on 31.12.11.
//  Copyright (c) 2011 Tim Schröder. All rights reserved.
//

#import "TSTableRowView.h"

@implementation TSTableRowView

// Draws the background of a not selected row
- (void)drawBackgroundInRect:(NSRect)dirtyRect
{   
    // Define the gradient and the background color, depending on if the application is currently in front or not
    NSGradient *gradient;
    gradient = [[NSGradient alloc] initWithStartingColor: [NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
                                             endingColor: [NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
    
    NSColor *fillColor = [NSColor whiteColor];
    [fillColor set];
    // Prepare drawing of the gradients and the background
    if ([self lockFocusIfCanDraw]) {
        NSRect drawingRect = [self bounds]; // ignore dirtyRect

        // Draw the gradient
        //[gradient drawInRect:drawingRect angle:90.0];
        [NSBezierPath fillRect:drawingRect];
    
        // Finished
        [self unlockFocus];
    }
}

// Draws the background of a selected row (including two gradients)
- (void)drawSelectionInRect:(NSRect)dirtyRect
{
    // Get the table view and info on row index numbers
    NSInteger ownRowNumber = -1;
    NSTableView *tableView;
    if ([[self superview] isKindOfClass:[NSTableView class]]) {
        tableView = (NSTableView*)[self superview]; // The table view the row is part of
        ownRowNumber = [tableView rowForView:self];
    } 

    // This is to have black colored text in the row even if the row is selected
    if ([self numberOfColumns] > 0) { 
        [[self viewAtColumn:0] setBackgroundStyle:NSBackgroundStyleLight]; // My table has only one column
    }
    
    // Define the gradient and the background color
    NSGradient *gradient;
    NSColor *backgroundColor;
    
    gradient = [[NSGradient alloc] initWithStartingColor: [NSColor colorWithCalibratedWhite:0.86 alpha:1.0]
                                                 endingColor: [NSColor colorWithCalibratedWhite:0.91 alpha:1.0]];
    backgroundColor = [NSColor colorWithCalibratedWhite:0.91 alpha:1.0];
    
    // Prepare drawing of the gradients and the background
    if ([self lockFocusIfCanDraw]) {
        NSRect drawingRect = [self bounds]; // ignore dirtyRect
        float height = drawingRect.size.height;
        float yOrigin = drawingRect.origin.y;
        float gradientHeightMultiplicator = 0.1; // i.e. 10 % of the height of the row view
        float gradientHeight = ceilf(height * gradientHeightMultiplicator);
            
        // Draw the top gradient
        drawingRect.size.height = gradientHeight;
        [gradient drawInRect:drawingRect angle:90.0];
        
        // Draw the bottom gradient
        drawingRect.origin.y = drawingRect.origin.y + height - gradientHeight - 1.0;
        [gradient drawInRect:drawingRect angle:270.0];
        
        // Draw the main background
        drawingRect.origin.y = yOrigin + gradientHeight - 1.0;
        drawingRect.size.height = height - (gradientHeight * 2.0) + 1.0; 
        [backgroundColor set];
        [NSBezierPath fillRect: drawingRect];
        
        // Draw Top/Bottom Line
        NSColor *lineColor = [NSColor colorWithDeviceRed:.75 green:.75 blue:.75 alpha:1.0];
        [lineColor set];
        
        // Draw Top Line
        if (ownRowNumber != 0) {
            drawingRect.size.height = 1.0; // Height of the separator line we're going to draw
            drawingRect.origin.y = 0.0;
            [NSBezierPath fillRect:drawingRect];
        }
        
        // Draw Bottom Line
        if (ownRowNumber == ([tableView numberOfRows]-1)) 
        {
            [[NSColor colorWithCalibratedWhite:.86 alpha:1.0] set];
        } 
        drawingRect.origin.y = height-1.0;
        [NSBezierPath fillRect:drawingRect];
        
        // Finished
        [self unlockFocus];
        
        for (id view in [self subviews]) [view setNeedsDisplay:YES];
    }
}



// Draws the (bottom) separator line of the row view

/*
- (void)drawSeparatorInRect:(NSRect)dirtyRect
{
    return;
    // Get the table view and info on row index numbers
    NSInteger selectedRowNumber;
    NSInteger ownRowNumber;
    NSTableView *tableView;
    if ([[self superview] isKindOfClass:[NSTableView class]]) {
        tableView = (NSTableView*)[self superview]; // The table view the row is part of
        selectedRowNumber = [tableView selectedRow];
        ownRowNumber = [tableView rowForView:self];
    } else {
        [super drawSeparatorInRect:dirtyRect];
        return;
    }
    
    // Define our drawing colors
    
    NSColor *normalColor = [NSColor colorWithCalibratedWhite:0.76 alpha:1.0]; // Default separator color
    
    NSColor *selectedTopColor = [NSColor colorWithDeviceRed:.0 green:.0 blue:.0 alpha:1.0];
    NSColor *selectedBottomColor = [NSColor colorWithDeviceRed:.5 green:.5 blue:1.0 alpha:1.0];
    
    
    // Define coordinates of bottom separator line
    NSRect drawingRect = [self frame]; // Ignore dirtyRect
    drawingRect.origin.y = drawingRect.size.height - 1.0;
    drawingRect.size.height = 1.0; // Height of the separator line we're going to draw at the bottom
    
    // Set the color of the separator line
    [normalColor set]; // Default
    if ([self isSelected]) [selectedBottomColor set]; // If the row is selected, use selectedBottomColor
    if ((![self isSelected]) && (selectedRowNumber > 0) && (ownRowNumber == (selectedRowNumber-1))) [selectedTopColor set]; // If the row is followed by the selected row, draw its bottom separator line in selectedTopColor
    
    // Draw bottom separator line
    [self lockFocus];
    [NSBezierPath fillRect: drawingRect];
    
    [self unlockFocus];
    
    // If the row is selected, tell the preceding row to redraw its bottom separator line (which is also the top line of the row)
    if (([self isSelected]) && (selectedRowNumber > 0)) [tableView setNeedsDisplayInRect:[tableView rectOfRow:selectedRowNumber-1]];
}
 */

@end
