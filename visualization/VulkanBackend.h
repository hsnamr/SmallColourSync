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
    void *physicalDevice; // VkPhysicalDevice
    void *device; // VkDevice
    void *surface; // VkSurfaceKHR
    void *swapchain; // VkSwapchainKHR
    void *renderPass; // VkRenderPass
    void *pipeline; // VkPipeline
    void *pipelineLayout; // VkPipelineLayout
    void *commandPool; // VkCommandPool
    void *graphicsQueue; // VkQueue
    void *presentQueue; // VkQueue
    NSMutableArray *gamutModels;
    NSMutableArray *vertexBuffers; // Array of NSValue wrapping VkBuffer*
    NSMutableArray *vertexBufferMemories; // Array of NSValue wrapping VkDeviceMemory*
    NSMutableArray *vertexCounts; // Array of NSNumber for vertex counts per model
    CIELABSpaceModel *labSpaceModel;
    float rotationX, rotationY;
    float zoom;
    float viewportWidth, viewportHeight;
    uint32_t swapchainImageCount;
    void **swapchainImages; // VkImage array
    void **swapchainImageViews; // VkImageView array
    void **framebuffers; // VkFramebuffer array
    void **commandBuffers; // VkCommandBuffer array
    BOOL initialized;
}

@end

NS_ASSUME_NONNULL_END
