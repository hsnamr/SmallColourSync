//
//  GamutViewPanel.h
//  SmallICCer
//
//  3D interactive view of the Lab space and gamut
//  Supports OpenGL, Vulkan (Linux), and Metal (macOS)
//

#import <AppKit/AppKit.h>
#import "RenderBackend.h"

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;
@class Renderer3D;

@interface GamutViewPanel : NSView {
    Renderer3D *renderer;
    ICCProfile *currentProfile;
    NSPoint lastMouseLocation;
    RenderBackendType preferredBackend;
}

- (id)initWithBackendType:(RenderBackendType)backendType;
- (void)displayProfile:(ICCProfile *)profile;
- (void)setPreferredBackend:(RenderBackendType)backendType;
- (void)refreshFromSettings; // Reapply settings (e.g. after preferences change) and redraw

@end

NS_ASSUME_NONNULL_END
