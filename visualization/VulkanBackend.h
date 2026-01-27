//
//  VulkanBackend.h
//  SmallICCer
//
//  Vulkan rendering backend for Linux
//

#import "RenderBackend.h"

NS_ASSUME_NONNULL_BEGIN

@interface VulkanBackend : NSObject <RenderBackend> {
    void *vulkanInstance; // VkInstance
    void *device; // VkDevice
    void *swapchain; // VkSwapchainKHR
    void *renderPass; // VkRenderPass
    NSMutableArray *gamutModels;
    CIELABSpaceModel *labSpaceModel;
    float rotationX, rotationY;
    float zoom;
    float viewportWidth, viewportHeight;
    BOOL initialized;
}

@end

NS_ASSUME_NONNULL_END
