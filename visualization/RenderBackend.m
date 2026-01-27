//
//  RenderBackend.m
//  SmallICCer
//
//  Render backend factory implementation
//

#import "RenderBackend.h"
#import "OpenGLBackend.h"
#import "VulkanBackend.h"
#import "MetalBackend.h"

@implementation RenderBackendFactory

+ (id<RenderBackend>)createBackend:(RenderBackendType)type {
    switch (type) {
        case RenderBackendTypeOpenGL:
            return [[[OpenGLBackend alloc] init] autorelease];
        case RenderBackendTypeVulkan:
            return [[[VulkanBackend alloc] init] autorelease];
        case RenderBackendTypeMetal:
            return [[[MetalBackend alloc] init] autorelease];
        default:
            return [[[OpenGLBackend alloc] init] autorelease];
    }
}

+ (RenderBackendType)defaultBackendType {
#if defined(__APPLE__) && !defined(__GNUSTEP__)
    // macOS: Prefer Metal, fallback to OpenGL
    return RenderBackendTypeMetal;
#elif defined(__GNUSTEP__) || defined(__linux__)
    // Linux: Prefer Vulkan, fallback to OpenGL
    return RenderBackendTypeVulkan;
#else
    return RenderBackendTypeOpenGL;
#endif
}

@end
