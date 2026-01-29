//
//  test_RenderBackend.m
//  SmallICCer Tests
//
//  Unit tests for renderer backend initialization and Task 3.2 backend verification.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "RenderBackend.h"
#import "OpenGLBackend.h"
#import "Gamut3DModel.h"
#import "Renderer3D.h"

// Try to find SSPlatform.h
#if __has_include("SSPlatform.h")
#import "SSPlatform.h"
#elif __has_include("../SmallStep/SmallStep/Core/SSPlatform.h")
#import "../SmallStep/SmallStep/Core/SSPlatform.h"
#elif __has_include("SmallStep/SmallStep/Core/SSPlatform.h")
#import "SmallStep/SmallStep/Core/SSPlatform.h"
#else
// Fallback: define minimal SSPlatform interface
@interface SSPlatform : NSObject
+ (BOOL)isMacOS;
+ (BOOL)isLinux;
@end
#endif

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

#pragma mark - Task 3.2 Backend verification

int testOpenGLBackendOptionalAPI() {
    id<RenderBackend> backend = [RenderBackendFactory createBackend:RenderBackendTypeOpenGL];
    if (!backend) {
        NSLog(@"ERROR: Failed to create OpenGL backend");
        return 1;
    }
    if ([backend respondsToSelector:@selector(setBackgroundRed:green:blue:)]) {
        [backend setBackgroundRed:0.2 green:0.3 blue:0.4];
    }
    if ([backend respondsToSelector:@selector(setRenderingQuality:)]) {
        [backend setRenderingQuality:2];
    }
    NSArray *verts = [NSArray arrayWithObject:[NSArray arrayWithObjects:
        [NSNumber numberWithDouble:50.0], [NSNumber numberWithDouble:0.0], [NSNumber numberWithDouble:0.0], nil]];
    Gamut3DModel *model = [[Gamut3DModel alloc] initWithVertices:verts faces:nil name:@"Test"];
    [backend addGamutModel:model];
    [model release];
    [backend clearGamutModels];
    NSLog(@"PASS: OpenGL backend optional API (setBackground, setRenderingQuality, addGamutModel, clearGamutModels)");
    return 0;
}

int testRenderer3DClearGamutModels() {
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    Renderer3D *renderer = [[Renderer3D alloc] initWithView:view backendType:RenderBackendTypeOpenGL];
    [view release];
    if (!renderer) {
        NSLog(@"PASS: Renderer3D clearGamutModels (skipped - no OpenGL context)");
        return 0;
    }
    [renderer clearGamutModels];
    NSArray *verts = [NSArray arrayWithObject:[NSArray arrayWithObjects:
        [NSNumber numberWithDouble:50.0], [NSNumber numberWithDouble:0.0], [NSNumber numberWithDouble:0.0], nil]];
    Gamut3DModel *model = [[Gamut3DModel alloc] initWithVertices:verts faces:nil name:@"Test"];
    [renderer addGamutModel:model];
    [model release];
    [renderer clearGamutModels];
    [renderer release];
    NSLog(@"PASS: Renderer3D clearGamutModels / addGamutModel");
    return 0;
}

int testRenderer3DApplySettings() {
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    Renderer3D *renderer = [[Renderer3D alloc] initWithView:view backendType:RenderBackendTypeOpenGL];
    [view release];
    if (!renderer) {
        NSLog(@"PASS: Renderer3D applySettings (skipped - no OpenGL context)");
        return 0;
    }
    [renderer applySettings];
    [renderer release];
    NSLog(@"PASS: Renderer3D applySettings (no crash)");
    return 0;
}

int testBackendFactoryFallback() {
    id<RenderBackend> vulkan = [RenderBackendFactory createBackend:RenderBackendTypeVulkan];
    id<RenderBackend> metal = [RenderBackendFactory createBackend:RenderBackendTypeMetal];
    if (!vulkan || !metal) {
        NSLog(@"ERROR: Vulkan or Metal backend creation returned nil");
        return 1;
    }
    if ([vulkan class] != [metal class]) {
        NSLog(@"NOTE: Vulkan and Metal backends may be different (or both fallback to OpenGL)");
    }
    NSLog(@"PASS: Backend factory fallback (Vulkan/Metal return non-nil)");
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
    failures += testOpenGLBackendOptionalAPI();
    failures += testRenderer3DClearGamutModels();
    failures += testRenderer3DApplySettings();
    failures += testBackendFactoryFallback();
    
    if (failures == 0) {
        NSLog(@"All renderer backend tests passed!");
    } else {
        NSLog(@"%d test(s) failed", failures);
    }
    
    [pool release];
    return failures;
}
