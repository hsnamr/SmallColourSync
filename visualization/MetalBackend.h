//
//  MetalBackend.h
//  SmallICCer
//
//  Metal rendering backend for macOS
//

#import "RenderBackend.h"

#if defined(__APPLE__) && !defined(__GNUSTEP__)
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <QuartzCore/CAMetalLayer.h>
#define HAVE_METAL 1
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MetalBackend : NSObject <RenderBackend> {
#if HAVE_METAL
    id<MTLDevice> device;
    id<MTLCommandQueue> commandQueue;
    CAMetalLayer *metalLayer;
    id<MTLRenderPipelineState> pipelineState;
#endif
    NSMutableArray *gamutModels;
    CIELABSpaceModel *labSpaceModel;
    float rotationX, rotationY;
    float zoom;
    float viewportWidth, viewportHeight;
    BOOL initialized;
}

@end

NS_ASSUME_NONNULL_END
