//
//  GamutViewPanel.h
//  SmallICCer
//
//  3D interactive view of the Lab space and gamut
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;
@class Renderer3D;

@interface GamutViewPanel : NSOpenGLView {
    Renderer3D *renderer;
    ICCProfile *currentProfile;
    NSPoint lastMouseLocation;
}

- (void)displayProfile:(ICCProfile *)profile;

@end

NS_ASSUME_NONNULL_END
