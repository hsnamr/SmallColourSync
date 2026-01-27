//
//  VulkanBackend.m
//  SmallICCer
//
//  Vulkan backend implementation for Linux
//

#import "VulkanBackend.h"
#import "Gamut3DModel.h"
#import "CIELABSpaceModel.h"
#import "VulkanShaderLoader.h"
#import <math.h>

#if (defined(__GNUSTEP__) || defined(__linux__)) && defined(HAVE_VULKAN)
#define VK_USE_PLATFORM_XLIB_KHR
#include <vulkan/vulkan.h>
#include <X11/Xlib.h>
#define HAVE_VULKAN 1
#else
#define HAVE_VULKAN 0
#endif

// Vertex structure for Lab space coordinates
typedef struct {
    float position[3]; // L*, a*, b*
    float color[3];    // RGB color
} Vertex;

@implementation VulkanBackend

- (id)init {
    self = [super init];
    if (self) {
        gamutModels = [[NSMutableArray alloc] init];
        vertexBuffers = [[NSMutableArray alloc] init];
        vertexBufferMemories = [[NSMutableArray alloc] init];
        vertexCounts = [[NSMutableArray alloc] init];
        rotationX = 0.0;
        rotationY = 0.0;
        zoom = 1.0;
        viewportWidth = 800.0;
        viewportHeight = 600.0;
        initialized = NO;
        vulkanInstance = NULL;
        physicalDevice = NULL;
        device = NULL;
        surface = NULL;
        swapchain = NULL;
        renderPass = NULL;
        pipeline = NULL;
        pipelineLayout = NULL;
        vertShaderModule = NULL;
        fragShaderModule = NULL;
        commandPool = NULL;
        graphicsQueue = NULL;
        presentQueue = NULL;
        swapchainImageCount = 0;
        swapchainImages = NULL;
        swapchainImageViews = NULL;
        framebuffers = NULL;
        commandBuffers = NULL;
    }
    return self;
}

- (BOOL)initializeWithView:(NSView *)view {
#if HAVE_VULKAN
    VkResult result;
    
    // 1. Create Vulkan instance
    VkApplicationInfo appInfo = {0};
    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName = "SmallICCer";
    appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.pEngineName = "SmallICCer";
    appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.apiVersion = VK_API_VERSION_1_0;
    
    const char *extensions[] = {
        VK_KHR_SURFACE_EXTENSION_NAME,
        VK_KHR_XLIB_SURFACE_EXTENSION_NAME
    };
    
    VkInstanceCreateInfo createInfo = {0};
    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pApplicationInfo = &appInfo;
    createInfo.enabledExtensionCount = 2;
    createInfo.ppEnabledExtensionNames = extensions;
    
    result = vkCreateInstance(&createInfo, NULL, (VkInstance *)&vulkanInstance);
    if (result != VK_SUCCESS) {
        NSLog(@"Failed to create Vulkan instance: %d", result);
        return NO;
    }
    
    // 2. Select physical device
    uint32_t deviceCount = 0;
    vkEnumeratePhysicalDevices((VkInstance)vulkanInstance, &deviceCount, NULL);
    if (deviceCount == 0) {
        NSLog(@"No Vulkan-capable devices found");
        return NO;
    }
    
    VkPhysicalDevice *devices = (VkPhysicalDevice *)malloc(deviceCount * sizeof(VkPhysicalDevice));
    vkEnumeratePhysicalDevices((VkInstance)vulkanInstance, &deviceCount, devices);
    physicalDevice = devices[0]; // Use first device
    free(devices);
    
    // 3. Find queue families
    uint32_t queueFamilyCount = 0;
    vkGetPhysicalDeviceQueueFamilyProperties((VkPhysicalDevice)physicalDevice, &queueFamilyCount, NULL);
    VkQueueFamilyProperties *queueFamilies = (VkQueueFamilyProperties *)malloc(queueFamilyCount * sizeof(VkQueueFamilyProperties));
    vkGetPhysicalDeviceQueueFamilyProperties((VkPhysicalDevice)physicalDevice, &queueFamilyCount, queueFamilies);
    
    uint32_t graphicsQueueFamily = UINT32_MAX;
    uint32_t presentQueueFamily = UINT32_MAX;
    uint32_t i;
    for (i = 0; i < queueFamilyCount; i++) {
        if (queueFamilies[i].queueFlags & VK_QUEUE_GRAPHICS_BIT) {
            graphicsQueueFamily = i;
        }
        // Check presentation support (simplified - would check with vkGetPhysicalDeviceXlibPresentationSupportKHR)
        if (presentQueueFamily == UINT32_MAX) {
            presentQueueFamily = i;
        }
    }
    free(queueFamilies);
    
    if (graphicsQueueFamily == UINT32_MAX) {
        NSLog(@"No graphics queue family found");
        return NO;
    }
    
    // 4. Create logical device
    float queuePriority = 1.0f;
    VkDeviceQueueCreateInfo queueCreateInfo = {0};
    queueCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
    queueCreateInfo.queueFamilyIndex = graphicsQueueFamily;
    queueCreateInfo.queueCount = 1;
    queueCreateInfo.pQueuePriorities = &queuePriority;
    
    const char *deviceExtensions[] = {
        VK_KHR_SWAPCHAIN_EXTENSION_NAME
    };
    
    VkDeviceCreateInfo deviceCreateInfo = {0};
    deviceCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    deviceCreateInfo.queueCreateInfoCount = 1;
    deviceCreateInfo.pQueueCreateInfos = &queueCreateInfo;
    deviceCreateInfo.enabledExtensionCount = 1;
    deviceCreateInfo.ppEnabledExtensionNames = deviceExtensions;
    
    result = vkCreateDevice((VkPhysicalDevice)physicalDevice, &deviceCreateInfo, NULL, (VkDevice *)&device);
    if (result != VK_SUCCESS) {
        NSLog(@"Failed to create logical device: %d", result);
        return NO;
    }
    
    // Get queues
    vkGetDeviceQueue((VkDevice)device, graphicsQueueFamily, 0, (VkQueue *)&graphicsQueue);
    vkGetDeviceQueue((VkDevice)device, presentQueueFamily, 0, (VkQueue *)&presentQueue);
    
    // 5. Create surface (simplified - would get X11 window from NSView)
    // For now, create a placeholder - full implementation would extract X11 window handle
    // VkXlibSurfaceCreateInfoKHR surfaceCreateInfo = {...};
    // vkCreateXlibSurfaceKHR(...);
    
    // 6. Create swapchain (simplified - would query surface capabilities first)
    // This is a placeholder - full implementation would:
    // - Query surface capabilities
    // - Choose swapchain format and present mode
    // - Create swapchain with proper extent
    
    // 7. Create render pass
    VkAttachmentDescription colorAttachment = {0};
    colorAttachment.format = VK_FORMAT_B8G8R8A8_UNORM; // Placeholder
    colorAttachment.samples = VK_SAMPLE_COUNT_1_BIT;
    colorAttachment.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
    colorAttachment.storeOp = VK_ATTACHMENT_STORE_OP_STORE;
    colorAttachment.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
    colorAttachment.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
    colorAttachment.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
    colorAttachment.finalLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
    
    VkAttachmentReference colorAttachmentRef = {0};
    colorAttachmentRef.attachment = 0;
    colorAttachmentRef.layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
    
    VkSubpassDescription subpass = {0};
    subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS;
    subpass.colorAttachmentCount = 1;
    subpass.pColorAttachments = &colorAttachmentRef;
    
    VkRenderPassCreateInfo renderPassInfo = {0};
    renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
    renderPassInfo.attachmentCount = 1;
    renderPassInfo.pAttachments = &colorAttachment;
    renderPassInfo.subpassCount = 1;
    renderPassInfo.pSubpasses = &subpass;
    
    result = vkCreateRenderPass((VkDevice)device, &renderPassInfo, NULL, (VkRenderPass *)&renderPass);
    if (result != VK_SUCCESS) {
        NSLog(@"Failed to create render pass: %d", result);
        return NO;
    }
    
    // 8. Create graphics pipeline
    [self createGraphicsPipeline];
    
    // 9. Create command pool
    VkCommandPoolCreateInfo poolInfo = {0};
    poolInfo.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
    poolInfo.queueFamilyIndex = graphicsQueueFamily;
    poolInfo.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
    
    result = vkCreateCommandPool((VkDevice)device, &poolInfo, NULL, (VkCommandPool *)&commandPool);
    if (result != VK_SUCCESS) {
        NSLog(@"Failed to create command pool: %d", result);
        return NO;
    }
    
    initialized = YES;
    return YES;
#else
    (void)view; // Suppress unused parameter warning
    return NO;
#endif
}

- (void)createGraphicsPipeline {
#if HAVE_VULKAN
    if (!device || !renderPass) return;
    
    // Create shader modules from SPIR-V bytecode
    // For now, we'll create a minimal pipeline without shaders
    // Full implementation would load compiled SPIR-V shaders
    
    // Vertex input binding
    VkVertexInputBindingDescription bindingDescription = {0};
    bindingDescription.binding = 0;
    bindingDescription.stride = sizeof(Vertex);
    bindingDescription.inputRate = VK_VERTEX_INPUT_RATE_VERTEX;
    
    // Vertex attributes
    VkVertexInputAttributeDescription attributeDescriptions[2] = {0};
    // Position attribute
    attributeDescriptions[0].binding = 0;
    attributeDescriptions[0].location = 0;
    attributeDescriptions[0].format = VK_FORMAT_R32G32B32_SFLOAT;
    attributeDescriptions[0].offset = offsetof(Vertex, position);
    // Color attribute
    attributeDescriptions[1].binding = 0;
    attributeDescriptions[1].location = 1;
    attributeDescriptions[1].format = VK_FORMAT_R32G32B32_SFLOAT;
    attributeDescriptions[1].offset = offsetof(Vertex, color);
    
    VkPipelineVertexInputStateCreateInfo vertexInputInfo = {0};
    vertexInputInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
    vertexInputInfo.vertexBindingDescriptionCount = 1;
    vertexInputInfo.pVertexBindingDescriptions = &bindingDescription;
    vertexInputInfo.vertexAttributeDescriptionCount = 2;
    vertexInputInfo.pVertexAttributeDescriptions = attributeDescriptions;
    
    // Input assembly
    VkPipelineInputAssemblyStateCreateInfo inputAssembly = {0};
    inputAssembly.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
    inputAssembly.topology = VK_PRIMITIVE_TOPOLOGY_POINT_LIST;
    inputAssembly.primitiveRestartEnable = VK_FALSE;
    
    // Viewport
    VkViewport viewport = {0};
    viewport.x = 0.0f;
    viewport.y = 0.0f;
    viewport.width = viewportWidth;
    viewport.height = viewportHeight;
    viewport.minDepth = 0.0f;
    viewport.maxDepth = 1.0f;
    
    VkRect2D scissor = {0};
    scissor.offset.x = 0;
    scissor.offset.y = 0;
    scissor.extent.width = (uint32_t)viewportWidth;
    scissor.extent.height = (uint32_t)viewportHeight;
    
    VkPipelineViewportStateCreateInfo viewportState = {0};
    viewportState.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO;
    viewportState.viewportCount = 1;
    viewportState.pViewports = &viewport;
    viewportState.scissorCount = 1;
    viewportState.pScissors = &scissor;
    
    // Rasterization
    VkPipelineRasterizationStateCreateInfo rasterizer = {0};
    rasterizer.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
    rasterizer.depthClampEnable = VK_FALSE;
    rasterizer.rasterizerDiscardEnable = VK_FALSE;
    rasterizer.polygonMode = VK_POLYGON_MODE_FILL;
    rasterizer.lineWidth = 1.0f;
    rasterizer.cullMode = VK_CULL_MODE_BACK_BIT;
    rasterizer.frontFace = VK_FRONT_FACE_CLOCKWISE;
    rasterizer.depthBiasEnable = VK_FALSE;
    
    // Multisampling
    VkPipelineMultisampleStateCreateInfo multisampling = {0};
    multisampling.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
    multisampling.sampleShadingEnable = VK_FALSE;
    multisampling.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT;
    
    // Color blending
    VkPipelineColorBlendAttachmentState colorBlendAttachment = {0};
    colorBlendAttachment.colorWriteMask = VK_COLOR_COMPONENT_R_BIT | VK_COLOR_COMPONENT_G_BIT | 
                                          VK_COLOR_COMPONENT_B_BIT | VK_COLOR_COMPONENT_A_BIT;
    colorBlendAttachment.blendEnable = VK_FALSE;
    
    VkPipelineColorBlendStateCreateInfo colorBlending = {0};
    colorBlending.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
    colorBlending.logicOpEnable = VK_FALSE;
    colorBlending.attachmentCount = 1;
    colorBlending.pAttachments = &colorBlendAttachment;
    
    // Pipeline layout (simplified - no uniforms for now)
    VkPipelineLayoutCreateInfo pipelineLayoutInfo = {0};
    pipelineLayoutInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
    pipelineLayoutInfo.setLayoutCount = 0;
    pipelineLayoutInfo.pushConstantRangeCount = 0;
    
    VkResult result = vkCreatePipelineLayout((VkDevice)device, &pipelineLayoutInfo, NULL, (VkPipelineLayout *)&pipelineLayout);
    if (result != VK_SUCCESS) {
        NSLog(@"Failed to create pipeline layout");
        return;
    }
    
    // Try to load shaders
    // Look for shaders in app bundle or current directory
    NSString *shaderPath = nil;
    NSBundle *bundle = [NSBundle mainBundle];
    if (bundle) {
        shaderPath = [bundle resourcePath];
    }
    if (!shaderPath) {
        shaderPath = @".";
    }
    
    NSString *vertPath = [shaderPath stringByAppendingPathComponent:@"simple.vert.spv"];
    NSString *fragPath = [shaderPath stringByAppendingPathComponent:@"simple.frag.spv"];
    
    NSData *vertShaderCode = [VulkanShaderLoader loadShaderFromFile:vertPath];
    NSData *fragShaderCode = [VulkanShaderLoader loadShaderFromFile:fragPath];
    
    VkShaderModule vertModule = VK_NULL_HANDLE;
    VkShaderModule fragModule = VK_NULL_HANDLE;
    
    if (vertShaderCode) {
        void *module = [VulkanShaderLoader createShaderModule:vertShaderCode device:device];
        if (module) {
            vertModule = *(VkShaderModule *)module;
            vertShaderModule = module;
        }
    }
    
    if (fragShaderCode) {
        void *module = [VulkanShaderLoader createShaderModule:fragShaderCode device:device];
        if (module) {
            fragModule = *(VkShaderModule *)module;
            fragShaderModule = module;
        }
    }
    
    // Create shader stages
    VkPipelineShaderStageCreateInfo shaderStages[2] = {0};
    uint32_t stageCount = 0;
    
    if (vertModule != VK_NULL_HANDLE) {
        shaderStages[stageCount].sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
        shaderStages[stageCount].stage = VK_SHADER_STAGE_VERTEX_BIT;
        shaderStages[stageCount].module = vertModule;
        shaderStages[stageCount].pName = "main";
        stageCount++;
    }
    
    if (fragModule != VK_NULL_HANDLE) {
        shaderStages[stageCount].sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
        shaderStages[stageCount].stage = VK_SHADER_STAGE_FRAGMENT_BIT;
        shaderStages[stageCount].module = fragModule;
        shaderStages[stageCount].pName = "main";
        stageCount++;
    }
    
    // Graphics pipeline create info
    VkGraphicsPipelineCreateInfo pipelineInfo = {0};
    pipelineInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
    pipelineInfo.stageCount = stageCount;
    pipelineInfo.pStages = (stageCount > 0) ? shaderStages : NULL;
    pipelineInfo.pVertexInputState = &vertexInputInfo;
    pipelineInfo.pInputAssemblyState = &inputAssembly;
    pipelineInfo.pViewportState = &viewportState;
    pipelineInfo.pRasterizationState = &rasterizer;
    pipelineInfo.pMultisampleState = &multisampling;
    pipelineInfo.pColorBlendState = &colorBlending;
    pipelineInfo.layout = (VkPipelineLayout)pipelineLayout;
    pipelineInfo.renderPass = (VkRenderPass)renderPass;
    pipelineInfo.subpass = 0;
    
    // Create pipeline
    if (stageCount > 0) {
        VkPipeline pipelineHandle;
        result = vkCreateGraphicsPipelines((VkDevice)device, VK_NULL_HANDLE, 1, &pipelineInfo, NULL, &pipelineHandle);
        if (result == VK_SUCCESS) {
            void *pipelinePtr = malloc(sizeof(VkPipeline));
            *(VkPipeline *)pipelinePtr = pipelineHandle;
            pipeline = pipelinePtr;
        } else {
            NSLog(@"Failed to create graphics pipeline: %d", result);
        }
    }
#endif
}

- (void)createVertexBuffers {
#if HAVE_VULKAN
    if (!device || !commandPool) return;
    
    // Clear existing buffers
    [self destroyVertexBuffers];
    
    // Create vertex buffer for each gamut model
    for (Gamut3DModel *model in gamutModels) {
        NSArray *vertices = [model vertices];
        if ([vertices count] == 0) continue;
        
        // Convert NSArray vertices to Vertex array
        NSUInteger vertexCount = [vertices count];
        Vertex *vertexData = (Vertex *)malloc(vertexCount * sizeof(Vertex));
        
        float *modelColor = [model color];
        NSUInteger i;
        for (i = 0; i < vertexCount; i++) {
            NSArray *point = [vertices objectAtIndex:i];
            if ([point count] >= 3) {
                vertexData[i].position[0] = [[point objectAtIndex:0] floatValue]; // L*
                vertexData[i].position[1] = [[point objectAtIndex:1] floatValue]; // a*
                vertexData[i].position[2] = [[point objectAtIndex:2] floatValue]; // b*
                vertexData[i].color[0] = modelColor[0];
                vertexData[i].color[1] = modelColor[1];
                vertexData[i].color[2] = modelColor[2];
            }
        }
        
        VkDeviceSize bufferSize = vertexCount * sizeof(Vertex);
        
        // Create staging buffer
        VkBuffer stagingBuffer;
        VkDeviceMemory stagingBufferMemory;
        [self createBuffer:bufferSize 
                     usage:VK_BUFFER_USAGE_TRANSFER_SRC_BIT 
            memoryProperties:VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT
                      buffer:&stagingBuffer 
                     memory:&stagingBufferMemory];
        
        // Copy data to staging buffer
        void *data;
        vkMapMemory((VkDevice)device, stagingBufferMemory, 0, bufferSize, 0, &data);
        memcpy(data, vertexData, bufferSize);
        vkUnmapMemory((VkDevice)device, stagingBufferMemory);
        
        free(vertexData);
        
        // Create vertex buffer
        VkBuffer vertexBuffer;
        VkDeviceMemory vertexBufferMemory;
        [self createBuffer:bufferSize 
                     usage:VK_BUFFER_USAGE_TRANSFER_DST_BIT | VK_BUFFER_USAGE_VERTEX_BUFFER_BIT 
            memoryProperties:VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT
                      buffer:&vertexBuffer 
                     memory:&vertexBufferMemory];
        
        // Copy from staging to vertex buffer
        [self copyBuffer:stagingBuffer to:vertexBuffer size:bufferSize];
        
        // Clean up staging buffer
        vkDestroyBuffer((VkDevice)device, stagingBuffer, NULL);
        vkFreeMemory((VkDevice)device, stagingBufferMemory, NULL);
        
        // Store buffers (allocate on heap to persist)
        VkBuffer *bufferPtr = (VkBuffer *)malloc(sizeof(VkBuffer));
        *bufferPtr = vertexBuffer;
        VkDeviceMemory *memoryPtr = (VkDeviceMemory *)malloc(sizeof(VkDeviceMemory));
        *memoryPtr = vertexBufferMemory;
        
        [vertexBuffers addObject:[NSValue valueWithPointer:bufferPtr]];
        [vertexBufferMemories addObject:[NSValue valueWithPointer:memoryPtr]];
        [vertexCounts addObject:[NSNumber numberWithUnsignedInteger:vertexCount]];
    }
#endif
}

- (void)createBuffer:(VkDeviceSize)size 
               usage:(VkBufferUsageFlags)usage 
      memoryProperties:(VkMemoryPropertyFlags)properties
                buffer:(VkBuffer *)buffer 
               memory:(VkDeviceMemory *)bufferMemory {
#if HAVE_VULKAN
    VkBufferCreateInfo bufferInfo = {0};
    bufferInfo.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
    bufferInfo.size = size;
    bufferInfo.usage = usage;
    bufferInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE;
    
    VkResult result = vkCreateBuffer((VkDevice)device, &bufferInfo, NULL, buffer);
    if (result != VK_SUCCESS) {
        NSLog(@"Failed to create buffer");
        return;
    }
    
    VkMemoryRequirements memRequirements;
    vkGetBufferMemoryRequirements((VkDevice)device, *buffer, &memRequirements);
    
    VkMemoryAllocateInfo allocInfo = {0};
    allocInfo.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
    allocInfo.allocationSize = memRequirements.size;
    allocInfo.memoryTypeIndex = [self findMemoryType:memRequirements.memoryTypeBits properties:properties];
    
    result = vkAllocateMemory((VkDevice)device, &allocInfo, NULL, bufferMemory);
    if (result != VK_SUCCESS) {
        NSLog(@"Failed to allocate buffer memory");
        return;
    }
    
    vkBindBufferMemory((VkDevice)device, *buffer, *bufferMemory, 0);
#endif
}

- (uint32_t)findMemoryType:(uint32_t)typeFilter properties:(VkMemoryPropertyFlags)properties {
#if HAVE_VULKAN
    VkPhysicalDeviceMemoryProperties memProperties;
    vkGetPhysicalDeviceMemoryProperties((VkPhysicalDevice)physicalDevice, &memProperties);
    
    uint32_t i;
    for (i = 0; i < memProperties.memoryTypeCount; i++) {
        if ((typeFilter & (1 << i)) && 
            (memProperties.memoryTypes[i].propertyFlags & properties) == properties) {
            return i;
        }
    }
#endif
    return 0;
}

- (void)copyBuffer:(VkBuffer)src to:(VkBuffer)dst size:(VkDeviceSize)size {
#if HAVE_VULKAN
    VkCommandBufferAllocateInfo allocInfo = {0};
    allocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    allocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    allocInfo.commandPool = (VkCommandPool)commandPool;
    allocInfo.commandBufferCount = 1;
    
    VkCommandBuffer commandBuffer;
    vkAllocateCommandBuffers((VkDevice)device, &allocInfo, &commandBuffer);
    
    VkCommandBufferBeginInfo beginInfo = {0};
    beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
    beginInfo.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
    
    vkBeginCommandBuffer(commandBuffer, &beginInfo);
    
    VkBufferCopy copyRegion = {0};
    copyRegion.size = size;
    vkCmdCopyBuffer(commandBuffer, src, dst, 1, &copyRegion);
    
    vkEndCommandBuffer(commandBuffer);
    
    VkSubmitInfo submitInfo = {0};
    submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;
    submitInfo.commandBufferCount = 1;
    submitInfo.pCommandBuffers = &commandBuffer;
    
    vkQueueSubmit((VkQueue)graphicsQueue, 1, &submitInfo, VK_NULL_HANDLE);
    vkQueueWaitIdle((VkQueue)graphicsQueue);
    
    vkFreeCommandBuffers((VkDevice)device, (VkCommandPool)commandPool, 1, &commandBuffer);
#endif
}

- (void)destroyVertexBuffers {
#if HAVE_VULKAN
    NSUInteger i;
    for (i = 0; i < [vertexBuffers count]; i++) {
        VkBuffer *buffer = (VkBuffer *)[[vertexBuffers objectAtIndex:i] pointerValue];
        VkDeviceMemory *memory = (VkDeviceMemory *)[[vertexBufferMemories objectAtIndex:i] pointerValue];
        if (buffer && *buffer != VK_NULL_HANDLE) {
            vkDestroyBuffer((VkDevice)device, *buffer, NULL);
            free(buffer);
        }
        if (memory && *memory != VK_NULL_HANDLE) {
            vkFreeMemory((VkDevice)device, *memory, NULL);
            free(memory);
        }
    }
    [vertexBuffers removeAllObjects];
    [vertexBufferMemories removeAllObjects];
    [vertexCounts removeAllObjects];
#endif
}

- (void)shutdown {
#if HAVE_VULKAN
    [self destroyVertexBuffers];
    
    if (commandPool) {
        vkDestroyCommandPool((VkDevice)device, (VkCommandPool)commandPool, NULL);
        commandPool = NULL;
    }
    if (pipeline) {
        vkDestroyPipeline((VkDevice)device, *(VkPipeline *)pipeline, NULL);
        free(pipeline);
        pipeline = NULL;
    }
    if (vertShaderModule) {
        vkDestroyShaderModule((VkDevice)device, *(VkShaderModule *)vertShaderModule, NULL);
        free(vertShaderModule);
        vertShaderModule = NULL;
    }
    if (fragShaderModule) {
        vkDestroyShaderModule((VkDevice)device, *(VkShaderModule *)fragShaderModule, NULL);
        free(fragShaderModule);
        fragShaderModule = NULL;
    }
    if (pipelineLayout) {
        vkDestroyPipelineLayout((VkDevice)device, (VkPipelineLayout)pipelineLayout, NULL);
        pipelineLayout = NULL;
    }
    if (renderPass) {
        vkDestroyRenderPass((VkDevice)device, (VkRenderPass)renderPass, NULL);
        renderPass = NULL;
    }
    if (swapchain) {
        // vkDestroySwapchainKHR would be called here
        swapchain = NULL;
    }
    if (surface) {
        // vkDestroySurfaceKHR would be called here
        surface = NULL;
    }
    if (device) {
        vkDestroyDevice((VkDevice)device, NULL);
        device = NULL;
    }
    if (vulkanInstance) {
        vkDestroyInstance((VkInstance)vulkanInstance, NULL);
        vulkanInstance = NULL;
    }
#endif
    [gamutModels removeAllObjects];
    initialized = NO;
}

- (void)render {
#if HAVE_VULKAN
    if (!initialized || !device || !commandPool || !renderPass) return;
    
    // Allocate command buffer if needed
    static VkCommandBuffer commandBuffer = VK_NULL_HANDLE;
    if (commandBuffer == VK_NULL_HANDLE) {
        VkCommandBufferAllocateInfo allocInfo = {0};
        allocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
        allocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
        allocInfo.commandPool = (VkCommandPool)commandPool;
        allocInfo.commandBufferCount = 1;
        
        VkResult result = vkAllocateCommandBuffers((VkDevice)device, &allocInfo, &commandBuffer);
        if (result != VK_SUCCESS) {
            return;
        }
    }
    
    // Begin command buffer
    VkCommandBufferBeginInfo beginInfo = {0};
    beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
    beginInfo.flags = 0;
    
    VkResult result = vkBeginCommandBuffer(commandBuffer, &beginInfo);
    if (result != VK_SUCCESS) {
        return;
    }
    
    // Begin render pass (simplified - would use actual framebuffer from swapchain)
    // Note: In full implementation with swapchain, would use:
    // VkClearValue clearColor = {{{0.1f, 0.1f, 0.1f, 1.0f}}};
    // VkRenderPassBeginInfo renderPassInfo = {...};
    // vkCmdBeginRenderPass(commandBuffer, &renderPassInfo, VK_SUBPASS_CONTENTS_INLINE);
    
    // Set viewport
    VkViewport viewport = {0};
    viewport.x = 0.0f;
    viewport.y = 0.0f;
    viewport.width = viewportWidth;
    viewport.height = viewportHeight;
    viewport.minDepth = 0.0f;
    viewport.maxDepth = 1.0f;
    vkCmdSetViewport(commandBuffer, 0, 1, &viewport);
    
    // Set scissor
    VkRect2D scissor = {0};
    scissor.offset.x = 0;
    scissor.offset.y = 0;
    scissor.extent.width = (uint32_t)viewportWidth;
    scissor.extent.height = (uint32_t)viewportHeight;
    vkCmdSetScissor(commandBuffer, 0, 1, &scissor);
    
    // Bind pipeline (if created)
    if (pipeline) {
        vkCmdBindPipeline(commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, *(VkPipeline *)pipeline);
    }
    
    // Draw gamut models
    NSUInteger i;
    for (i = 0; i < [vertexBuffers count]; i++) {
        VkBuffer *buffer = (VkBuffer *)[[vertexBuffers objectAtIndex:i] pointerValue];
        NSNumber *count = [vertexCounts objectAtIndex:i];
        if (buffer && *buffer != VK_NULL_HANDLE && count) {
            VkDeviceSize offsets[] = {0};
            vkCmdBindVertexBuffers(commandBuffer, 0, 1, buffer, offsets);
            vkCmdDraw(commandBuffer, [count unsignedIntegerValue], 1, 0, 0);
        }
    }
    
    // End render pass (when render pass is begun)
    // vkCmdEndRenderPass(commandBuffer);
    
    // End command buffer
    result = vkEndCommandBuffer(commandBuffer);
    if (result != VK_SUCCESS) {
        return;
    }
    
    // Submit to queue
    VkSubmitInfo submitInfo = {0};
    submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;
    submitInfo.commandBufferCount = 1;
    submitInfo.pCommandBuffers = &commandBuffer;
    
    vkQueueSubmit((VkQueue)graphicsQueue, 1, &submitInfo, VK_NULL_HANDLE);
    vkQueueWaitIdle((VkQueue)graphicsQueue);
    
    // Note: In full implementation, would:
    // - Present swapchain image
    // - Use semaphores for synchronization
    // - Not wait for queue idle (use fences instead)
#endif
}

- (void)setViewportWidth:(float)width height:(float)height {
    viewportWidth = width;
    viewportHeight = height;
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
    // Recreate vertex buffers when a new model is added
    if (initialized) {
        [self createVertexBuffers];
    }
}

- (void)setLabSpaceModel:(CIELABSpaceModel *)model {
    [labSpaceModel release];
    labSpaceModel = [model retain];
}

- (void)clearGamutModels {
    [gamutModels removeAllObjects];
    [self destroyVertexBuffers];
}

- (void)dealloc {
    [self shutdown];
    [gamutModels release];
    [vertexBuffers release];
    [vertexBufferMemories release];
    [vertexCounts release];
    [labSpaceModel release];
    [super dealloc];
}

@end
