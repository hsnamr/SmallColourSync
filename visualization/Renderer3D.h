//
//  Renderer3D.h
//  SmallICCer
//
//  3D rendering with multiple backend support (OpenGL, Vulkan, Metal)
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "RenderBackend.h"

NS_ASSUME_NONNULL_BEGIN

@class Gamut3DModel;
@class CIELABSpaceModel;

@interface Renderer3D : NSObject {
    id<RenderBackend> backend;
    float rotationX, rotationY;
    float zoom;
    RenderBackendType backendType;
}

- (id)initWithView:(NSView *)view backendType:(RenderBackendType)type;
- (id)initWithView:(NSView *)view; // Uses default backend
- (void)render;
- (void)addGamutModel:(Gamut3DModel *)model;
- (void)clearGamutModels;
- (void)setLabSpaceModel:(CIELABSpaceModel *)model;
- (void)handleMouseDrag:(NSPoint)delta;
- (void)handleZoom:(float)delta;
- (void)setViewportWidth:(float)width height:(float)height;
- (void)applySettings; // Apply SettingsManager (background color, rendering quality)
- (RenderBackendType)backendType;

@end

NS_ASSUME_NONNULL_END
