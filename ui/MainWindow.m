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
        
        // Create panels
        profileInspector = [[ProfileInspectorPanel alloc] init];
        tagEditor = [[TagEditorPanel alloc] init];
        gamutView = [[GamutViewPanel alloc] init];
        histogramCurves = [[HistogramAndCurvesPanel alloc] init];
        fileBrowser = [[FileBrowserPanel alloc] initWithAppController:controller];
        
        // Set up window content view with panels
        // (Simplified - would use proper layout in full implementation)
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
