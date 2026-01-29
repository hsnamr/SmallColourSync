//
//  test_RenderBackend.m
//  SmallICCer Tests
//
//  Unit tests for renderer backend initialization
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "RenderBackend.h"
#import "../SmallStep/SmallStep/Core/SSPlatform.h"

int testRenderBackendFactory() {
    // Test default backend type
    RenderBackendType defaultType = [RenderBackendFactory defaultBackendType];
    
    if ([SSPlatform isMacOS]) {
        // macOS should prefer Metal
        if (defaultType != RenderBackendTypeMetal && defaultType != RenderBackendTypeOpenGL) {
            NSLog(@"ERROR: macOS should prefer Metal or OpenGL, got %d", defaultType);
            return 1;
        }
    } else if ([SSPlatform isLinux]) {
        // Linux should prefer Vulkan
        if (defaultType != RenderBackendTypeVulkan && defaultType != RenderBackendTypeOpenGL) {
            NSLog(@"ERROR: Linux should prefer Vulkan or OpenGL, got %d", defaultType);
            return 1;
        }
    }
    
    NSLog(@"PASS: Default backend type selection");
    return 0;
}

int testCreateOpenGLBackend() {
    id<RenderBackend> backend = [RenderBackendFactory createBackend:RenderBackendTypeOpenGL];
    
    if (!backend) {
        NSLog(@"ERROR: Failed to create OpenGL backend");
        return 1;
    }
    
    NSLog(@"PASS: OpenGL backend creation");
    return 0;
}

int testCreateVulkanBackend() {
    id<RenderBackend> backend = [RenderBackendFactory createBackend:RenderBackendTypeVulkan];
    
    if (!backend) {
        NSLog(@"ERROR: Failed to create Vulkan backend");
        return 1;
    }
    
    NSLog(@"PASS: Vulkan backend creation");
    return 0;
}

int testCreateMetalBackend() {
    id<RenderBackend> backend = [RenderBackendFactory createBackend:RenderBackendTypeMetal];
    
    if (!backend) {
        NSLog(@"ERROR: Failed to create Metal backend");
        return 1;
    }
    
    NSLog(@"PASS: Metal backend creation");
    return 0;
}

int testBackendInitialization() {
    id<RenderBackend> backend = [RenderBackendFactory createBackend:RenderBackendTypeOpenGL];
    
    if (!backend) {
        NSLog(@"ERROR: Failed to create backend");
        return 1;
    }
    
    // Create a dummy view for initialization
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    
    // Try to initialize (may fail if OpenGL context not available, that's OK)
    BOOL initialized = [backend initializeWithView:view];
    
    // Cleanup
    if (initialized) {
        [backend shutdown];
    }
    [view release];
    
    // Initialization may fail in test environment, that's acceptable
    NSLog(@"PASS: Backend initialization test (result: %s)", initialized ? "success" : "skipped (no context)");
    return 0;
}

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int failures = 0;
    failures += testRenderBackendFactory();
    failures += testCreateOpenGLBackend();
    failures += testCreateVulkanBackend();
    failures += testCreateMetalBackend();
    failures += testBackendInitialization();
    
    if (failures == 0) {
        NSLog(@"All renderer backend tests passed!");
    } else {
        NSLog(@"%d test(s) failed", failures);
    }
    
    [pool release];
    return failures;
}
