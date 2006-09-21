/* Copyright (C) 1996 Dave Vasilevsky
 * This file is licensed under the GNU General Public License,
 * see the file Copying.txt for details. */

#import "FLView.h"

#import "FLRadialPainter.h"

@implementation FLView

#pragma mark Tracking

- (void) setTrackingRect
{    
    NSPoint mouse = [[self window] mouseLocationOutsideOfEventStream];
    NSPoint where = [self convertPoint: mouse fromView: nil];
    BOOL inside = ([self hitTest: where] == self);
    
    trackingRect = [self addTrackingRect: [self visibleRect]
                                   owner: self
                                userData: NULL
                            assumeInside: inside];
    if (inside) {
        [self mouseEntered: nil];
    }
}

- (void) clearTrackingRect
{
	[self removeTrackingRect: trackingRect];
}

- (BOOL) acceptsFirstResponder
{    
    return YES;
}

- (BOOL) becomeFirstResponder
{
    return YES;
}

- (void) resetCursorRects
{
	[super resetCursorRects];
	[self clearTrackingRect];
	[self setTrackingRect];
}

-(void) viewWillMoveToWindow: (NSWindow *) win
{
	if (!win && [self window]) {
        [self clearTrackingRect];
    }
}

-(void) viewDidMoveToWindow
{
	if ([self window]) {
        [self setTrackingRect];
    }
}

- (void) mouseEntered: (NSEvent *) event
{
    wasAcceptingMouseEvents = [[self window] acceptsMouseMovedEvents];
    [[self window] setAcceptsMouseMovedEvents: YES];
    [[self window] makeFirstResponder: self];
}

- (void) mouseExited: (NSEvent *) event
{
    [[self window] setAcceptsMouseMovedEvents: wasAcceptingMouseEvents];
    [display setStringValue: @""];
}

- (void) mouseMoved: (NSEvent *) event
{
    NSPoint where = [self convertPoint: [event locationInWindow] fromView: nil];
    id item = [painter itemAt: where
                       center: [self center]
                       radius: [self maxRadius]];
    if (item != nil) {
        [display setStringValue: [item path]];
    } else {
        [display setStringValue: @""];
    }
}


#pragma mark Drawing

- (void) drawRect: (NSRect)rect
{
    [painter drawInView: self
                   rect: rect
                 center: [self center]
                 radius: [self maxRadius]];
}

- (void) awakeFromNib
{
    [painter addObserver: self
              forKeyPath: @"dataSource.rootPath"
                 options: NSKeyValueObservingOptionNew
                 context: NULL];
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object 
                         change: (NSDictionary *) change
                        context: (void *) context
{
    if (object == painter) {
        [self setNeedsDisplay: YES];
    }
}

@end