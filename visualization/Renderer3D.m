//
//  Renderer3D.m
//  SmallICCer
//
//  3D Renderer with multiple backend support
//

#import "Renderer3D.h"
#import "Gamut3DModel.h"
#import "CIELABSpaceModel.h"
#import "RenderBackend.h"

@implementation Renderer3D

- (id)initWithView:(NSView *)view backendType:(RenderBackendType)type {
    self = [super init];
    if (self) {
        backendType = type;
        backend = [RenderBackendFactory createBackend:type];
        [backend retain];
        
        if (![backend initializeWithView:view]) {
            // Fallback to OpenGL if requested backend fails
            if (type != RenderBackendTypeOpenGL) {
                [backend release];
                backend = [RenderBackendFactory createBackend:RenderBackendTypeOpenGL];
                [backend retain];
                backendType = RenderBackendTypeOpenGL;
                if (![backend initializeWithView:view]) {
                    [backend release];
                    backend = nil;
                    return nil;
                }
            } else {
                [backend release];
                backend = nil;
                return nil;
            }
        }
        
        rotationX = 0.0;
        rotationY = 0.0;
        zoom = 1.0;
    }
    return self;
}

- (id)initWithView:(NSView *)view {
    RenderBackendType defaultType = [RenderBackendFactory defaultBackendType];
    return [self initWithView:view backendType:defaultType];
}

- (void)render {
    if (backend) {
        [backend setCameraRotationX:rotationX rotationY:rotationY zoom:zoom];
        [backend render];
    }
}

- (void)addGamutModel:(Gamut3DModel *)model {
    if (backend) {
        [backend addGamutModel:model];
    }
}

- (void)setLabSpaceModel:(CIELABSpaceModel *)model {
    if (backend) {
        [backend setLabSpaceModel:model];
    }
}

- (void)handleMouseDrag:(NSPoint)delta {
    rotationY += delta.x * 0.5;
    rotationX += delta.y * 0.5;
}

- (void)handleZoom:(float)delta {
    zoom += delta;
    if (zoom < 0.1) zoom = 0.1;
    if (zoom > 10.0) zoom = 10.0;
}

- (void)setViewportWidth:(float)width height:(float)height {
    if (backend) {
        [backend setViewportWidth:width height:height];
    }
}

- (RenderBackendType)backendType {
    return backendType;
}

- (void)dealloc {
    if (backend) {
        [backend shutdown];
        [backend release];
    }
    [super dealloc];
}

@end
