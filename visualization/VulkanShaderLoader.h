//
//  VulkanShaderLoader.h
//  SmallICCer
//
//  Helper for loading SPIR-V shaders for Vulkan
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VulkanShaderLoader : NSObject

+ (NSData *)loadShaderFromFile:(NSString *)path;
+ (void *)createShaderModule:(NSData *)shaderCode device:(void *)device; // Returns VkShaderModule

@end

NS_ASSUME_NONNULL_END
