//
//  MetalBackend.m
//  SmallICCer
//
//  Metal backend implementation for macOS
//

#import "MetalBackend.h"
#import "Gamut3DModel.h"
#import "CIELABSpaceModel.h"
#import <math.h>

@implementation MetalBackend

- (id)init {
    self = [super init];
    if (self) {
        gamutModels = [[NSMutableArray alloc] init];
        rotationX = 0.0;
        rotationY = 0.0;
        zoom = 1.0;
        viewportWidth = 800.0;
        viewportHeight = 600.0;
        initialized = NO;
#if HAVE_METAL
        device = nil;
        commandQueue = nil;
        metalLayer = nil;
        pipelineState = nil;
#endif
    }
    return self;
}

- (BOOL)initializeWithView:(NSView *)view {
#if HAVE_METAL && defined(__APPLE__) && !defined(__GNUSTEP__)
    // Get Metal device
    device = MTLCreateSystemDefaultDevice();
    if (!device) {
        NSLog(@"Metal is not supported on this device");
        return NO;
    }
    
    // Create command queue
    commandQueue = [device newCommandQueue];
    if (!commandQueue) {
        return NO;
    }
    
    // Create Metal layer
    metalLayer = [CAMetalLayer layer];
    metalLayer.device = device;
    metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    metalLayer.framebufferOnly = YES;
    
    // Set layer as view's layer
    [view setWantsLayer:YES];
    [view setLayer:metalLayer];
    
    // Create render pipeline descriptor
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    // Create shader library (simplified - would load from .metal file)
    // For now, use default shaders if available
    id<MTLLibrary> library = [device newDefaultLibrary];
    if (library) {
        id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_main"];
        id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_main"];
        
        if (vertexFunction && fragmentFunction) {
            pipelineDescriptor.vertexFunction = vertexFunction;
            pipelineDescriptor.fragmentFunction = fragmentFunction;
            
            NSError *error = nil;
            pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
            if (!pipelineState) {
                NSLog(@"Failed to create pipeline state: %@", error);
                NSLog(@"Note: Metal shaders need to be compiled. Using fallback rendering.");
                // Continue without pipeline state - will use basic rendering
            }
        }
    }
    [pipelineDescriptor release];
    
    initialized = YES;
    return YES;
#else
    (void)view; // Suppress unused parameter warning
    return NO;
#endif
}

- (void)shutdown {
#if HAVE_METAL
    pipelineState = nil;
    metalLayer = nil;
    commandQueue = nil;
    device = nil;
#endif
    [gamutModels removeAllObjects];
    initialized = NO;
}

- (void)render {
#if HAVE_METAL && defined(__APPLE__) && !defined(__GNUSTEP__)
    if (!initialized || !metalLayer || !commandQueue) return;
    
    @autoreleasepool {
        // Get drawable
        id<CAMetalDrawable> drawable = [metalLayer nextDrawable];
        if (!drawable) return;
        
        // Create command buffer
        id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
        
        // Create render pass descriptor
        MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.1, 0.1, 0.1, 1.0);
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        
        // Create render encoder
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        if (renderEncoder && pipelineState) {
            [renderEncoder setRenderPipelineState:pipelineState];
            
            // Set viewport
            MTLViewport viewport = {0, 0, viewportWidth, viewportHeight, 0.0, 1.0};
            [renderEncoder setViewport:viewport];
            
            // Calculate camera matrix
            float camDist = 200.0 / zoom;
            float radX = rotationX * M_PI / 180.0;
            float radY = rotationY * M_PI / 180.0;
            
            float camX = camDist * sin(radY) * cos(radX);
            float camY = camDist * sin(radX);
            float camZ = camDist * cos(radY) * cos(radX);
            
            // Set uniforms (simplified - would use proper matrix)
            // [renderEncoder setVertexBytes:&cameraMatrix length:sizeof(matrix_float4x4) atIndex:0];
            
            // Render gamut models
            for (Gamut3DModel *model in gamutModels) {
                [self renderGamutModel:model withEncoder:renderEncoder];
            }
            
            [renderEncoder endEncoding];
        }
        
        // Present drawable
        [commandBuffer presentDrawable:drawable];
        [commandBuffer commit];
    }
#endif
}

- (void)renderGamutModel:(Gamut3DModel *)model withEncoder:(id<MTLRenderCommandEncoder>)encoder {
#if HAVE_METAL && defined(__APPLE__) && !defined(__GNUSTEP__)
    // Render gamut model using Metal
    // This would:
    // 1. Create vertex buffer from model vertices
    // 2. Set vertex buffer
    // 3. Set color uniform
    // 4. Draw primitives
    
    // Simplified placeholder - full implementation would create and bind buffers
    // For now, this is a skeleton that can be expanded with proper Metal rendering code
    (void)model;
    (void)encoder;
#endif
}

- (void)setViewportWidth:(float)width height:(float)height {
    viewportWidth = width;
    viewportHeight = height;
#if HAVE_METAL
    if (metalLayer) {
        CGSize drawableSize = CGSizeMake(width, height);
        metalLayer.drawableSize = drawableSize;
    }
#endif
}

- (void)setCameraRotationX:(float)rotX rotationY:(float)rotY zoom:(float)z {
    rotationX = rotX;
    rotationY = rotY;
    zoom = z;
    if (zoom < 0.1) zoom = 0.1;
    if (zoom > 10.0) zoom = 10.0;
}

- (void)addGamutModel:(Gamut3DModel *)model {
    [gamutModels addObject:model];
}

- (void)setLabSpaceModel:(CIELABSpaceModel *)model {
    [labSpaceModel release];
    labSpaceModel = [model retain];
}

- (void)clearGamutModels {
    [gamutModels removeAllObjects];
}

- (void)dealloc {
    [self shutdown];
    [gamutModels release];
    [labSpaceModel release];
    [super dealloc];
}

@end
