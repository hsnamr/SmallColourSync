//
//  MetalBackend.h
//  SmallICCer
//
//  Metal rendering backend for macOS
//

#import "RenderBackend.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetalBackend : NSObject <RenderBackend> {
#if defined(__APPLE__) && !defined(__GNUSTEP__)
    id device; // id<MTLDevice>
    id commandQueue; // id<MTLCommandQueue>
    id metalLayer; // CAMetalLayer *
    id pipelineState; // id<MTLRenderPipelineState>
#define HAVE_METAL 1
#else
#define HAVE_METAL 0
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
