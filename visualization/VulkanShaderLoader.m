//
//  VulkanShaderLoader.m
//  SmallICCer
//
//  Shader loader implementation
//

#import "VulkanShaderLoader.h"

#if (defined(__GNUSTEP__) || defined(__linux__)) && defined(HAVE_VULKAN)
#include <vulkan/vulkan.h>
#define HAVE_VULKAN 1
#else
#define HAVE_VULKAN 0
#endif

@implementation VulkanShaderLoader

+ (NSData *)loadShaderFromFile:(NSString *)path {
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!file) {
        NSLog(@"Failed to open shader file: %@", path);
        return nil;
    }
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    return data;
}

+ (void *)createShaderModule:(NSData *)shaderCode device:(void *)device {
#if HAVE_VULKAN
    if (!shaderCode || !device) {
        return NULL;
    }
    
    VkShaderModuleCreateInfo createInfo = {0};
    createInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
    createInfo.codeSize = [shaderCode length];
    createInfo.pCode = (const uint32_t *)[shaderCode bytes];
    
    VkShaderModule shaderModule;
    VkResult result = vkCreateShaderModule((VkDevice)device, &createInfo, NULL, &shaderModule);
    if (result != VK_SUCCESS) {
        NSLog(@"Failed to create shader module: %d", result);
        return NULL;
    }
    
    void *modulePtr = malloc(sizeof(VkShaderModule));
    *(VkShaderModule *)modulePtr = shaderModule;
    return modulePtr;
#else
    return NULL;
#endif
}

@end
