//
//  OpenGLBackend.h
//  SmallICCer
//
//  OpenGL rendering backend
//

#import "RenderBackend.h"
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenGLBackend : NSObject <RenderBackend> {
    NSOpenGLContext *glContext;
    NSMutableArray *gamutModels;
    CIELABSpaceModel *labSpaceModel;
    float rotationX, rotationY;
    float zoom;
    float viewportWidth, viewportHeight;
    float backgroundRed, backgroundGreen, backgroundBlue;
    NSInteger renderingQuality;
}

@end

NS_ASSUME_NONNULL_END
