package game_desktop

import "core:c"

VkApplicationInfo :: struct {
    sType: u32,
    pNext: rawptr,
    pApplicationName: ^c.char,
    applicationVersion: u32,
    pEngineName: ^c.char,
    engineVersion: u32,
    apiVersion: u32,
}

VkInstanceCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    pApplicationInfo: ^VkApplicationInfo,
    enabledLayerCount: u32,
    ppEnabledLayerNames: ^ ^c.char,
    enabledExtensionCount: u32,
    ppEnabledExtensionNames: ^ ^c.char,
}

VkAllocationCallbacks :: struct {
    pUserData: rawptr,
    pfnAllocation: rawptr,
    pfnReallocation: rawptr,
    pfnFree: rawptr,
    pfnInternalAllocation: rawptr,
    pfnInternalFree: rawptr,
}

VkDebugUtilsMessengerCreateInfoEXT :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    messageSeverity: u32,
    messageType: u32,
    pfnUserCallback: rawptr,
    pUserData: rawptr,
}

VkDebugUtilsMessengerCallbackDataEXT :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    pMessageIdName: ^c.char,
    messageIdNumber: i32,
    pMessage: ^c.char,
    queueLabelCount: u32,
    pQueueLabels: rawptr,
    labelCount: u32,
    pLabels: rawptr,
    cmdBufLabelCount: u32,
    pCmdBufLabels: rawptr,
}

VkDebugUtilsObjectNameInfoEXT :: struct {
    sType: u32,
    pNext: rawptr,
    objectType: u32,
    objectHandle: u64,
    pObjectName: ^c.char,
}

VK_STRUCTURE_TYPE_APPLICATION_INFO :: u32(0)
VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO :: u32(1)
VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO :: u32(5)
VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO :: u32(6)
VK_STRUCTURE_TYPE_DEVICE_QUEUE_GLOBAL_PRIORITY_CREATE_INFO_KHR :: u32(1000298000)
VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2 :: u32(1001229967)
VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2 :: u32(1001229969)
VK_STRUCTURE_TYPE_FORMAT_PROPERTIES_2 :: u32(1001229964)
VK_STRUCTURE_TYPE_IMAGE_FORMAT_PROPERTIES_2 :: u32(1001229965)
VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_FORMAT_INFO_2 :: u32(1001229966)
VK_STRUCTURE_TYPE_MEMORY_WIN32_HANDLE_PROPERTIES_KHR :: u32(1000072003)
VK_STRUCTURE_TYPE_MEMORY_GET_WIN32_HANDLE_INFO_KHR :: u32(1000072004)
VK_STRUCTURE_TYPE_MEMORY_GET_WIN32_HANDLE_PROPERTIES_KHR :: u32(1000072005)
VK_STRUCTURE_TYPE_EXTERNAL_IMAGE_FORMAT_PROPERTIES_NV :: u32(1000134003)
VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_IMAGE_FORMAT_INFO_NV :: u32(1000134002)
VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_BUFFER_CREATE_INFO_NV :: u32(1000132002)
VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO_NV :: u32(1000132003)
VK_STRUCTURE_TYPE_EXPORT_FENCE_CREATE_INFO_NV :: u32(1000130004)
VK_STRUCTURE_TYPE_EXPORT_SEMAPHORE_CREATE_INFO_NV :: u32(1000079004)
VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SURFACE_INFO_2_KHR :: u32(1000120001)
VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES_2_KHR :: u32(1000120002)
VK_STRUCTURE_TYPE_SURFACE_FORMAT_2_KHR :: u32(1000120003)
VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR :: u32(1000001001)
VK_STRUCTURE_TYPE_PRESENT_INFO_KHR :: u32(1000001003)
VK_STRUCTURE_TYPE_DEVICE_GROUP_PRESENT_CAPABILITIES_KHR :: u32(1000060006)
VK_STRUCTURE_TYPE_DEVICE_GROUP_PRESENT_INFO_KHR :: u32(1000060007)
VK_STRUCTURE_TYPE_DEVICE_GROUP_SWAPCHAIN_PRESENT_INFO_KHR :: u32(1000060008)
VK_STRUCTURE_TYPE_DEVICE_GROUP_BIND_SPARSE_INFO_KHR :: u32(1000060009)
VK_STRUCTURE_TYPE_BIND_SPARSE_INFO_KHR :: u32(1000192007)
VK_STRUCTURE_TYPE_WAIT_FENCES_INFO_KHR :: u32(1000192009)
VK_STRUCTURE_TYPE_SIGNAL_EVENT_INFO_KHR :: u32(1000192010)
VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_GROUP_PROPERTIES_KHR :: u32(1000070003)
VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_DEVICE_GROUP_INFO_KHR :: u32(1000192013)
VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_INFO :: u32(1000167001)
VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_INFO :: u32(1000167002)
VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_DEVICE_GROUP_INFO :: u32(1000167006)
VK_STRUCTURE_TYPE_DEVICE_GROUP_BIND_SPARSE_INFO :: u32(1000170001)
VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    size: VkDeviceSize,
    usage: u32,
    sharingMode: u32,
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: ^u32,
}

when ODIN_OS == "windows" {
    VkWin32SurfaceCreateInfoKHR :: struct {
        sType: u32,
        pNext: rawptr,
        flags: u32,
        hinstance: rawptr,
        hwnd: rawptr,
    }
}

when ODIN_OS == "linux" {
    VkXlibSurfaceCreateInfoKHR :: struct {
        sType: u32,
        pNext: rawptr,
        flags: u32,
        dpy: rawptr,
        window: rawptr,
    }

    VkXcbSurfaceCreateInfoKHR :: struct {
        sType: u32,
        pNext: rawptr,
        flags: u32,
        connection: rawptr,
        window: u64,
    }

    VkWaylandSurfaceCreateInfoKHR :: struct {
        sType: u32,
        pNext: rawptr,
        flags: u32,
        display: rawptr,
        surface: rawptr,
    }
}

VkSurfaceCreateInfoKHR :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
}

VkSwapchainCreateInfoKHR :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    surface: VkSurfaceKHR,
    minImageCount: u32,
    imageFormat: u32,
    imageColorSpace: u32,
    imageExtent: VkExtent2D,
    imageArrayLayers: u32,
    imageUsage: u32,
    imageSharingMode: u32,
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: ^u32,
    preTransform: u32,
    compositeAlpha: u32,
    presentMode: u32,
    clipped: bool,
    oldSwapchain: VkSwapchainKHR,
}

VkImageCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    imageType: u32,
    format: VkFormat,
    extent: VkExtent3D,
    mipLevels: u32,
    arrayLayers: u32,
    samples: u32,
    tiling: u32,
    usage: u32,
    sharingMode: u32,
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: ^u32,
}

VkSwapchainCreateInfoKHR :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    surface: VkSurfaceKHR,
    minImageCount: u32,
    imageFormat: u32,
    imageColorSpace: u32,
    imageExtent: VkExtent2D,
    imageArrayLayers: u32,
    imageUsage: u32,
    imageSharingMode: u32,
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: ^u32,
    preTransform: u32,
    compositeAlpha: u32,
    presentMode: u32,
    clipped: bool,
    oldSwapchain: VkSwapchainKHR,
}

VkImageCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    imageType: u32,
    format: VkFormat,
    extent: VkExtent3D,
    mipLevels: u32,
    arrayLayers: u32,
    samples: u32,
    tiling: u32,
    usage: u32,
    sharingMode: u32,
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: ^u32,
    initialLayout: u32,
}

VkImageViewCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    image: VkImage,
    viewType: u32,
    format: VkFormat,
    components: VkComponentMapping,
    subresourceRange: VkImageSubresourceRange,
}

VkComponentMapping :: struct {
    r: u32,
    g: u32,
    b: u32,
    a: u32,
}

VkSamplerCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    magFilter: u32,
    minFilter: u32,
    mipmapMode: u32,
    addressModeU: u32,
    addressModeV: u32,
    addressModeW: u32,
    mipLodBias: f32,
    anisotropyEnable: bool,
    maxAnisotropy: f32,
    compareEnable: bool,
    compareOp: u32,
    minLod: f32,
    maxLod: f32,
    borderColor: u32,
    unnormalizedCoordinates: bool,
}

VkDescriptorSetLayoutCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    bindingCount: u32,
    pBindings: ^VkDescriptorSetLayoutBinding,
}

VkDescriptorSetLayoutBinding :: struct {
    binding: u32,
    descriptorType: u32,
    descriptorCount: u32,
    stageFlags: u32,
    pImmutableSamplers: ^VkSampler,
}

VkDescriptorPoolCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    maxSets: u32,
    poolSizeCount: u32,
    pPoolSizes: ^VkDescriptorPoolSize,
}

VkDescriptorPoolSize :: struct {
    type: u32,
    descriptorCount: u32,
}

VkDescriptorSetAllocateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    descriptorPool: VkDescriptorSet,
    descriptorSetCount: u32,
    pSetLayouts: ^VkDescriptorSetLayout,
}

VkWriteDescriptorSet :: struct {
    sType: u32,
    pNext: rawptr,
    dstSet: VkDescriptorSet,
    dstBinding: u32,
    dstArrayElement: u32,
    descriptorCount: u32,
    descriptorType: u32,
    pImageInfo: ^VkDescriptorImageInfo,
    pBufferInfo: ^VkDescriptorBufferInfo,
    pTexelBufferView: ^VkBufferView,
}

VkCopyDescriptorSet :: struct {
    sType: u32,
    pNext: rawptr,
    srcSet: VkDescriptorSet,
    srcBinding: u32,
    srcArrayElement: u32,
    dstSet: VkDescriptorSet,
    dstBinding: u32,
    dstArrayElement: u32,
    descriptorCount: u32,
}

VkDescriptorImageInfo :: struct {
    sampler: VkSampler,
    imageView: VkImageView,
    imageLayout: u32,
}

VkDescriptorBufferInfo :: struct {
    buffer: VkBuffer,
    offset: VkDeviceSize,
    range: VkDeviceSize,
}

VkFramebufferCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    renderPass: VkRenderPass,
    attachmentCount: u32,
    pAttachments: ^VkImageView,
    width: u32,
    height: u32,
    layers: u32,
}

VkRenderPassCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    attachmentCount: u32,
    pAttachments: ^VkAttachmentDescription,
    subpassCount: u32,
    pSubpasses: ^VkSubpassDescription,
    dependencyCount: u32,
    pDependencies: ^VkSubpassDependency,
}

VkAttachmentDescription :: struct {
    flags: u32,
    format: VkFormat,
    samples: u32,
    loadOp: u32,
    storeOp: u32,
    stencilLoadOp: u32,
    stencilStoreOp: u32,
    initialLayout: u32,
    finalLayout: u32,
}

VkAttachmentReference :: struct {
    attachment: u32,
    layout: u32,
}

VkSubpassDependency :: struct {
    srcSubpass: u32,
    dstSubpass: u32,
    srcStageMask: u32,
    dstStageMask: u32,
    srcAccessMask: u32,
    dstAccessMask: u32,
    dependencyFlags: u32,
}

VkSubpassDescription :: struct {
    flags: u32,
    pipelineBindPoint: u32,
    inputAttachmentCount: u32,
    pInputAttachments: ^VkAttachmentReference,
    colorAttachmentCount: u32,
    pColorAttachments: ^VkAttachmentReference,
    pResolveAttachments: ^VkAttachmentReference,
    pDepthStencilAttachment: ^VkAttachmentReference,
    preserveAttachmentCount: u32,
    pPreserveAttachments: ^u32,
}

VkCommandPoolCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    queueFamilyIndex: u32,
}

VkCommandBufferAllocateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    commandPool: VkCommandPool,
    level: u32,
    commandBufferCount: u32,
}

VkCommandBufferBeginInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    pInheritanceInfo: ^VkCommandBufferInheritanceInfo,
}

VkCommandBufferInheritanceInfo :: struct {
    sType: u32,
    pNext: rawptr,
    renderPass: VkRenderPass,
    subpass: u32,
    framebuffer: VkFramebuffer,
    occlusionQueryEnable: bool,
    queryFlags: u32,
    prevPipelineStats: u32,
}

VkSubmitInfo :: struct {
    sType: u32,
    pNext: rawptr,
    waitSemaphoreCount: u32,
    pWaitSemaphores: ^VkSemaphore,
    pWaitDstStageMask: ^u32,
    commandBufferCount: u32,
    pCommandBuffers: ^VkCommandBuffer,
    signalSemaphoreCount: u32,
    pSignalSemaphores: ^VkSemaphore,
}

VkPresentInfoKHR :: struct {
    sType: u32,
    pNext: rawptr,
    waitSemaphoreCount: u32,
    pWaitSemaphores: ^VkSemaphore,
    swapchainCount: u32,
    pSwapchains: ^VkSwapchainKHR,
    pImageIndices: ^u32,
    pResults: ^VkResult,
}

VkFenceCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
}

VkSemaphoreCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
}

VkEventCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
}

VkQueryPoolCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    queryType: u32,
    queryCount: u32,
    pipelineStatistics: u32,
}

VkPipelineCacheCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    initialDataSize: c.size_t,
    pInitialData: rawptr,
}

VkPipelineShaderStageCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    stage: u32,
    module: VkShaderModule,
    pName: ^c.char,
    pSpecializationInfo: ^VkSpecializationInfo,
}

VkSpecializationInfo :: struct {
    mapEntryCount: u32,
    pMapEntries: ^VkSpecializationMapEntry,
    dataSize: c.size_t,
    pData: rawptr,
}

VkSpecializationMapEntry :: struct {
    constantID: u32,
    offset: u32,
    size: c.size_t,
}

VkPipelineVertexInputStateCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    vertexBindingDescriptionCount: u32,
    pVertexBindingDescriptions: ^VkVertexInputBindingDescription,
    vertexAttributeDescriptionCount: u32,
    pVertexAttributeDescriptions: ^VkVertexInputAttributeDescription,
}

VkVertexInputBindingDescription :: struct {
    binding: u32,
    stride: u32,
    inputRate: u32,
}

VkVertexInputAttributeDescription :: struct {
    location: u32,
    binding: u32,
    format: u32,
    offset: u32,
}

VkPipelineInputAssemblyStateCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    topology: u32,
    primitiveRestartEnable: bool,
}

VkPipelineViewportStateCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    viewportCount: u32,
    pViewports: ^VkViewport,
    scissorCount: u32,
    pScissors: ^VkRect2D,
}

VkPipelineRasterizationStateCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    depthClampEnable: bool,
    rasterizerDiscardEnable: bool,
    polygonMode: u32,
    cullMode: u32,
    frontFace: u32,
    depthBiasEnable: bool,
    depthBiasConstantFactor: f32,
    depthBiasClamp: f32,
    depthBiasSlopeFactor: f32,
    lineWidth: f32,
}

VkPipelineMultisampleStateCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    rasterizationSamples: u32,
    sampleShadingEnable: bool,
    minSampleShading: f32,
    pSampleMask: ^u32,
    alphaToCoverageEnable: bool,
    alphaToOneEnable: bool,
    sampleLocationsEnable: bool,
    pSampleLocations: ^VkSampleLocations,
}

VkSampleLocations :: struct {
    sampleLocationsPerPixel: u32,
    sampleLocationGridSize: VkExtent2D,
    sampleLocationsCount: u32,
    pSampleLocations: ^VkSampleLocationInfo,
}

VkSampleLocationInfo :: struct {
    x: f32,
    y: f32,
}

VkPipelineColorBlendStateCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    logicOpEnable: bool,
    logicOp: u32,
    attachmentCount: u32,
    pAttachments: ^VkPipelineColorBlendAttachmentState,
    blendConstants: [4]f32,
}

VkPipelineColorBlendAttachmentState :: struct {
    blendEnable: bool,
    srcColorBlendFactor: u32,
    dstColorBlendFactor: u32,
    colorBlendOp: u32,
    srcAlphaBlendFactor: u32,
    dstAlphaBlendFactor: u32,
    alphaBlendOp: u32,
    colorWriteMask: u32,
}

VkPipelineDepthStencilStateCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    depthTestEnable: bool,
    depthWriteEnable: bool,
    depthCompareOp: u32,
    depthBoundsTestEnable: bool,
    stencilTestEnable: bool,
    front: VkStencilOpState,
    back: VkStencilOpState,
    minDepthBounds: f32,
    maxDepthBounds: f32,
}

VkStencilOpState :: struct {
    failOp: u32,
    passOp: u32,
    depthFailOp: u32,
    compareOp: u32,
    compareMask: u32,
    writeMask: u32,
    reference: u32,
}

VkGraphicsPipelineCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    stageCount: u32,
    pStages: ^VkPipelineShaderStageCreateInfo,
    pVertexInputState: ^VkPipelineVertexInputStateCreateInfo,
    pInputAssemblyState: ^VkPipelineInputAssemblyStateCreateInfo,
    pTessellationState: ^VkPipelineTessellationStateCreateInfo,
    pViewportState: ^VkPipelineViewportStateCreateInfo,
    pRasterizationState: ^VkPipelineRasterizationStateCreateInfo,
    pMultisampleState: ^VkPipelineMultisampleStateCreateInfo,
    pDepthStencilState: ^VkPipelineDepthStencilStateCreateInfo,
    pColorBlendState: ^VkPipelineColorBlendStateCreateInfo,
    pDynamicState: ^VkPipelineDynamicStateCreateInfo,
    layout: VkPipelineLayout,
    renderPass: VkRenderPass,
    subpass: u32,
    basePipelineHandle: VkPipeline,
    basePipelineIndex: i32,
}

VkComputePipelineCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    stage: VkPipelineShaderStageCreateInfo,
    layout: VkPipelineLayout,
    basePipelineHandle: VkPipeline,
    basePipelineIndex: i32,
}

VkPipelineDynamicStateCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    dynamicStateCount: u32,
    pDynamicStates: ^u32,
}

VkPipelineLayoutCreateInfo :: struct {
    sType: u32,
    pNext: rawptr,
    flags: u32,
    setLayoutCount: u32,
    pSetLayouts: ^VkDescriptorSetLayout,
    pushConstantRangeCount: u32,
    pPushConstantRanges: ^VkPushConstantRange,
}

VkPushConstantRange :: struct {
    stageFlags: u32,
    offset: u32,
    size: u32,
}

VkPhysicalDeviceXrandrPresentationSupportKhr :: struct {
    connectorCount: u32,
    pConnectors: rawptr,
}

VkClearRect :: struct {
    rect: VkRect2D,
    baseArrayLayer: u32,
    layerCount: u32,
}

VkClearAttachment :: struct {
    aspectMask: u32,
    colorAttachment: u32,
    clear: VkClearValue,
}

VK_TRUE :: u32(1)
VK_FALSE :: u32(0)

VK_SUBPASS_EXTERNAL :: u32(0xFFFFFFFF)

VK_IMAGE_LAYOUT_UNDEFINED :: u32(0x00000000)
VK_IMAGE_LAYOUT_GENERAL :: u32(0x00000001)
VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL :: u32(0x00000002)
VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL :: u32(0x00000003)
VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL :: u32(0x00000004)
VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL :: u32(0x00000005)
VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL :: u32(0x00000006)
VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL :: u32(0x00000007)
VK_IMAGE_LAYOUT_PREINITIALIZED :: u32(0x00000008)
VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL :: u32(0x00000009)
VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL :: u32(0x0000000a)
VK_IMAGE_LAYOUT_PRESENT_SRC_KHR :: u32(0x1000001002)

VK_FILTER_NEAREST :: u32(0x00000000)
VK_FILTER_LINEAR :: u32(0x00000001)
VK_FILTER_CUBIC_IMG :: u32(0x00000002)

VK_SAMPLER_MIPMAP_MODE_NEAREST :: u32(0x00000000)
VK_SAMPLER_MIPMAP_MODE_LINEAR :: u32(0x00000001)

VK_SAMPLER_ADDRESS_MODE_REPEAT :: u32(0x00000000)
VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT :: u32(0x00000001)
VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE :: u32(0x00000002)
VK_SAMPLER_ADDRESS_MODE_MIRROR_CLAMP_TO_EDGE :: u32(0x00000003)
VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER :: u32(0x00000004)

VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK :: u32(0)
VK_BORDER_COLOR_INT_TRANSPARENT_BLACK :: u32(0)
VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK :: u32(0)
VK_BORDER_COLOR_INT_OPAQUE_BLACK :: u32(0)
VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE :: u32(0)
VK_BORDER_COLOR_INT_OPAQUE_WHITE :: u32(0)

VK_DESCRIPTOR_TYPE_SAMPLER :: u32(0)
VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER :: u32(1)
VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE :: u32(2)
VK_DESCRIPTOR_TYPE_STORAGE_IMAGE :: u32(3)
VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER :: u32(4)
VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER :: u32(5)
VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER :: u32(6)
VK_DESCRIPTOR_TYPE_STORAGE_BUFFER :: u32(7)
VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC :: u32(8)
VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC :: u32(9)

VK_INDIRECT_COMPUTE_BIT :: u32(0x00000001)
VK_INDIRECT_VERTEX_BIT :: u32(0x00000002)

VK_INDEX_TYPE_UINT16 :: u32(0)
VK_INDEX_TYPE_UINT32 :: u32(1)
VK_INDEX_TYPE_NONE_KHR :: u32(1000265000)