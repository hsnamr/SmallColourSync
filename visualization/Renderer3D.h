//
//  Renderer3D.h
//  SmallICCer
//
//  3D rendering using OpenGL
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Gamut3DModel;
@class CIELABSpaceModel;

@class Gamut3DModel;
@class CIELABSpaceModel;

@interface Renderer3D : NSObject {
    NSOpenGLContext *glContext;
    float cameraX, cameraY, cameraZ;
    float rotationX, rotationY;
    float zoom;
    NSMutableArray *gamutModels;
    CIELABSpaceModel *labSpaceModel;
}

- (id)initWithView:(NSOpenGLView *)view;
- (void)render;
- (void)addGamutModel:(Gamut3DModel *)model;
- (void)setLabSpaceModel:(CIELABSpaceModel *)model;
- (void)handleMouseDrag:(NSPoint)delta;
- (void)handleZoom:(float)delta;

@end

NS_ASSUME_NONNULL_END
