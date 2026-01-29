//
//  RenderBackend.m
//  SmallICCer
//
//  Render backend factory implementation
//

#import "RenderBackend.h"
#import "OpenGLBackend.h"
#import "SSPlatform.h"

// Conditionally import backends (only if available)
// Note: For tests, we only need OpenGLBackend
// VulkanBackend and MetalBackend require platform-specific headers

@implementation RenderBackendFactory

+ (id<RenderBackend>)createBackend:(RenderBackendType)type {
    switch (type) {
        case RenderBackendTypeOpenGL:
            return [[[OpenGLBackend alloc] init] autorelease];
        case RenderBackendTypeVulkan:
            // Vulkan backend requires platform-specific setup
            // For now, fall back to OpenGL
            return [[[OpenGLBackend alloc] init] autorelease];
        case RenderBackendTypeMetal:
            // Metal backend requires macOS
            // For now, fall back to OpenGL
            return [[[OpenGLBackend alloc] init] autorelease];
        default:
            return [[[OpenGLBackend alloc] init] autorelease];
    }
}

+ (RenderBackendType)defaultBackendType {
    if ([SSPlatform isMacOS]) {
        // macOS: Prefer Metal, fallback to OpenGL
        return RenderBackendTypeMetal;
    } else if ([SSPlatform isLinux]) {
        // Linux: Prefer Vulkan, fallback to OpenGL
        return RenderBackendTypeVulkan;
    } else {
        return RenderBackendTypeOpenGL;
    }
}

@end
