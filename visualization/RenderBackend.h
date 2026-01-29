//
//  RenderBackend.h
//  SmallICCer
//
//  Abstract rendering backend interface
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Gamut3DModel;
@class CIELABSpaceModel;

typedef enum {
    RenderBackendTypeOpenGL,
    RenderBackendTypeVulkan,
    RenderBackendTypeMetal
} RenderBackendType;

@protocol RenderBackend <NSObject>

- (BOOL)initializeWithView:(NSView *)view;
- (void)shutdown;
- (void)render;
- (void)setViewportWidth:(float)width height:(float)height;
- (void)setCameraRotationX:(float)rotX rotationY:(float)rotY zoom:(float)zoom;
- (void)addGamutModel:(Gamut3DModel *)model;
- (void)setLabSpaceModel:(CIELABSpaceModel *)model;
- (void)clearGamutModels;

@optional
- (void)setBackgroundRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b;
- (void)setRenderingQuality:(NSInteger)quality; // 0=low, 1=medium, 2=high

@end

@interface RenderBackendFactory : NSObject

+ (id<RenderBackend>)createBackend:(RenderBackendType)type;
+ (RenderBackendType)defaultBackendType;

@end

NS_ASSUME_NONNULL_END
