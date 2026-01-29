//
//  GamutViewPanel.h
//  SmallICCer
//
//  3D interactive view of the Lab space and gamut
//  Supports OpenGL, Vulkan (Linux), and Metal (macOS)
//  Includes GamutComparator UI: add standard spaces, toggle visibility, colors, stats.
//

#import <AppKit/AppKit.h>
#import "RenderBackend.h"

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;
@class Renderer3D;

@interface GamutViewPanel : NSView <NSTableViewDataSource, NSTableViewDelegate> {
    Renderer3D *renderer;
    NSView *glContentView;           // View passed to renderer (e.g. NSOpenGLView)
    ICCProfile *currentProfile;
    NSPoint lastMouseLocation;
    RenderBackendType preferredBackend;
    NSMutableArray *comparisonEntries; // Array of dicts: @"model" -> Gamut3DModel, @"visible" -> NSNumber
    NSView *comparisonPanel;
    NSPopUpButton *addComparisonPopUp;
    NSTableView *comparisonTableView;
    NSTextField *statsTextField;
    CGFloat comparisonPanelWidth;
}

- (id)initWithBackendType:(RenderBackendType)backendType;
- (void)displayProfile:(ICCProfile *)profile;
- (void)setPreferredBackend:(RenderBackendType)backendType;
- (void)refreshFromSettings;

@end

NS_ASSUME_NONNULL_END
