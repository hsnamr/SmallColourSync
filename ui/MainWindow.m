//
//  MainWindow.m
//  SmallICCer
//
//  Main Window implementation
//

#import "MainWindow.h"
#import "AppController.h"
#import "ICCProfile.h"
#import "ProfileInspectorPanel.h"
#import "TagEditorPanel.h"
#import "GamutViewPanel.h"
#import "HistogramAndCurvesPanel.h"
#import "FileBrowserPanel.h"

@implementation MainWindow

@synthesize appController;
@synthesize profileInspector;
@synthesize tagEditor;
@synthesize gamutView;
@synthesize histogramCurves;
@synthesize fileBrowser;

- (id)initWithAppController:(AppController *)controller {
    NSRect contentRect = NSMakeRect(100, 100, 1200, 800);
    self = [super initWithContentRect:contentRect
                             styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                               backing:NSBackingStoreBuffered
                                 defer:NO];
    if (self) {
        appController = [controller retain];
        
        // Create main content view
        NSView *contentView = [self contentView];
        NSRect bounds = [contentView bounds];
        
        // Create file browser at top
        fileBrowser = [[FileBrowserPanel alloc] initWithAppController:controller];
        NSRect fileBrowserFrame = NSMakeRect(0, bounds.size.height - 50, bounds.size.width, 50);
        [fileBrowser setFrame:fileBrowserFrame];
        [fileBrowser setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        [contentView addSubview:fileBrowser];
        
        // Create split view for main content
        NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 0, bounds.size.width, bounds.size.height - 50)];
        [splitView setVertical:YES];
        [splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        // Left panel: Profile Inspector and Tag Editor
        NSView *leftPanel = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 400, bounds.size.height - 50)];
        NSSplitView *leftSplit = [[NSSplitView alloc] initWithFrame:[leftPanel bounds]];
        [leftSplit setVertical:NO];
        [leftSplit setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        profileInspector = [[ProfileInspectorPanel alloc] init];
        [profileInspector setFrame:NSMakeRect(0, 0, 400, 300)];
        [profileInspector setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        tagEditor = [[TagEditorPanel alloc] init];
        [tagEditor setFrame:NSMakeRect(0, 0, 400, 200)];
        [tagEditor setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [leftSplit addSubview:profileInspector];
        [leftSplit addSubview:tagEditor];
        [leftPanel addSubview:leftSplit];
        [leftSplit release];
        
        // Right panel: Gamut View and Histogram
        NSView *rightPanel = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 800, bounds.size.height - 50)];
        NSSplitView *rightSplit = [[NSSplitView alloc] initWithFrame:[rightPanel bounds]];
        [rightSplit setVertical:NO];
        [rightSplit setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        gamutView = [[GamutViewPanel alloc] init];
        [gamutView setFrame:NSMakeRect(0, 0, 800, 500)];
        [gamutView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        histogramCurves = [[HistogramAndCurvesPanel alloc] init];
        [histogramCurves setFrame:NSMakeRect(0, 0, 800, 200)];
        [histogramCurves setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [rightSplit addSubview:gamutView];
        [rightSplit addSubview:histogramCurves];
        [rightPanel addSubview:rightSplit];
        [rightSplit release];
        
        [splitView addSubview:leftPanel];
        [splitView addSubview:rightPanel];
        [leftPanel release];
        [rightPanel release];
        
        [contentView addSubview:splitView];
        [splitView release];
        
        [self setTitle:@"SmallICCer - ICC Profile Editor"];
    }
    return self;
}

- (void)profileDidLoad:(ICCProfile *)profile {
    [profileInspector displayProfile:profile];
    [tagEditor displayProfile:profile];
    [gamutView displayProfile:profile];
}

- (void)dealloc {
    [appController release];
    [profileInspector release];
    [tagEditor release];
    [gamutView release];
    [histogramCurves release];
    [fileBrowser release];
    [super dealloc];
}

@end
