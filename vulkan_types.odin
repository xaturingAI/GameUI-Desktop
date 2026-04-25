package game_desktop

import "core:c"

VkInstance :: distinct u64
VkPhysicalDevice :: distinct u64
VkDevice :: distinct u64
VkQueue :: distinct u64
VkSemaphore :: distinct u64
VkCommandBuffer :: distinct u64
VkFence :: distinct u64
VkDeviceMemory :: distinct u64
VkBuffer :: distinct u64
VkBufferView :: distinct u64
VkImage :: distinct u64
VkImageView :: distinct u64
VkShaderModule :: distinct u64
VkPipeline :: distinct u64
VkPipelineCache :: distinct u64
VkPipelineLayout :: distinct u64
VkRenderPass :: distinct u64
VkFramebuffer :: distinct u64
VkDescriptorSetLayout :: distinct u64
VkDescriptorSet :: distinct u64
VkDescriptorPool :: distinct u64
VkSampler :: distinct u64
VkSurfaceKHR :: distinct u64
VkSwapchainKHR :: distinct u64
VkEvent :: distinct u64
VkQueryPool :: distinct u64
VkGroupMemberPropertiesKHR :: distinct u64

VkResult :: distinct i32

VK_SUCCESS :: VkResult(0)
VK_NOT_READY :: VkResult(1)
VK_TIMEOUT :: VkResult(2)
VK_EVENT_SET :: VkResult(3)
VK_EVENT_RESET :: VkResult(4)
VK_INCOMPLETE :: VkResult(5)
VK_ERROR_OUT_OF_HOST_MEMORY :: VkResult(-1)
VK_ERROR_OUT_OF_DEVICE_MEMORY :: VkResult(-2)
VK_ERROR_INITIALIZATION_FAILED :: VkResult(-3)
VK_ERROR_DEVICE_LOST :: VkResult(-4)
VK_ERROR_MEMORY_MAP_FAILED :: VkResult(-5)
VK_ERROR_LAYER_NOT_PRESENT :: VkResult(-6)
VK_ERROR_EXTENSION_NOT_PRESENT :: VkResult(-7)
VK_ERROR_FEATURE_NOT_PRESENT :: VkResult(-8)
VK_ERROR_INCOMPATIBLE_DRIVER :: VkResult(-9)
VK_ERROR_TOO_MANY_OBJECTS :: VkResult(-10)
VK_ERROR_FORMAT_NOT_SUPPORTED :: VkResult(-11)
VK_ERROR_FRAGMENTED_POOL :: VkResult(-12)
VK_ERROR_UNKNOWN :: VkResult(-13)
VK_ERROR_SURFACE_LOST_KHR :: VkResult(-1000000000)
VK_ERROR_NATIVE_WINDOW_IN_USE_KHR :: VkResult(-1000000001)
VK_ERROR_OUT_OF_POOL_MEMORY :: VkResult(-1000021000)
VK_ERROR_INVALID_EXTERNAL_HANDLE_KHR :: VkResult(-1000072000)
VK_ERROR_FRAGMENTATION_EXT :: VkResult(-1000161000)
VK_ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT :: VkResult(-1000158000)
VK_ERROR_NOT_PERMITTED_KHR :: VkResult(-1000174001)
VK_ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT :: VkResult(-1000255000)

when ODIN_OS == "windows" {
    VkWin32SurfaceCreateFlagsKHR :: distinct u32
}
when ODIN_OS == "linux" {
    VkXlibSurfaceCreateFlagsKHR :: distinct u32
    VkXcbSurfaceCreateFlagsKHR :: distinct u32
    VkWaylandSurfaceCreateFlagsKHR :: distinct u32
}

VkSurfaceTransformFlagBitsKHR :: distinct u32
VkCompositeAlphaFlagBitsKHR :: distinct u32
VkPresentModeKHR :: distinct u32
VkColorSpaceKHR :: distinct u32
VkSurfaceDisplayPlaneCreateModeFlagsEXT :: distinct u32

VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR :: VkSurfaceTransformFlagBitsKHR(1)
VK_SURFACE_TRANSFORM_ROTATE_90_BIT_KHR :: VkSurfaceTransformFlagBitsKHR(2)
VK_SURFACE_TRANSFORM_ROTATE_180_BIT_KHR :: VkSurfaceTransformFlagBitsKHR(4)
VK_SURFACE_TRANSFORM_ROTATE_270_BIT_KHR :: VkSurfaceTransformFlagBitsKHR(8)
VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_BIT_KHR :: VkSurfaceTransformFlagBitsKHR(16)
VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_90_BIT_KHR :: VkSurfaceTransformFlagBitsKHR(32)
VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_180_BIT_KHR :: VkSurfaceTransformFlagBitsKHR(64)
VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_270_BIT_KHR :: VkSurfaceTransformFlagBitsKHR(128)
VK_SURFACE_TRANSFORM_INHERIT_BIT_KHR :: VkSurfaceTransformFlagBitsKHR(256)

VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR :: VkCompositeAlphaFlagBitsKHR(1)
VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR :: VkCompositeAlphaFlagBitsKHR(2)
VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR :: VkCompositeAlphaFlagBitsKHR(4)
VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR :: VkCompositeAlphaFlagBitsKHR(8)

VK_PRESENT_MODE_IMMEDIATE_KHR :: VkPresentModeKHR(0)
VK_PRESENT_MODE_MAILBOX_KHR :: VkPresentModeKHR(1)
VK_PRESENT_MODE_FIFO_KHR :: VkPresentModeKHR(2)
VK_PRESENT_MODE_FIFO_RELAXED_KHR :: VkPresentModeKHR(3)

VkFormat :: distinct u32

VK_FORMAT_UNDEFINED :: VkFormat(0)
VK_FORMAT_R4G4_UNORM_PACK8 :: VkFormat(1)
VK_FORMAT_R4G4B4A4_UNORM_PACK16 :: VkFormat(2)
VK_FORMAT_B4G4R4A4_UNORM_PACK16 :: VkFormat(3)
VK_FORMAT_R5G5B5A1_UNORM_PACK16 :: VkFormat(4)
VK_FORMAT_B5G5R5A1_UNORM_PACK16 :: VkFormat(5)
VK_FORMAT_R8_UNORM :: VkFormat(9)
VK_FORMAT_R8_SNORM :: VkFormat(10)
VK_FORMAT_R8_USCALED :: VkFormat(11)
VK_FORMAT_R8_SSCALED :: VkFormat(12)
VK_FORMAT_R8_UINT :: VkFormat(13)
VK_FORMAT_R8_SINT :: VkFormat(14)
VK_FORMAT_R8G8_UNORM :: VkFormat(16)
VK_FORMAT_R8G8_SNORM :: VkFormat(17)
VK_FORMAT_R8G8_USCALED :: VkFormat(18)
VK_FORMAT_R8G8_SSCALED :: VkFormat(19)
VK_FORMAT_R8G8_UINT :: VkFormat(20)
VK_FORMAT_R8G8_SINT :: VkFormat(21)
VK_FORMAT_R8G8B8_UNORM :: VkFormat(23)
VK_FORMAT_R8G8B8_SNORM :: VkFormat(24)
VK_FORMAT_R8G8B8_USCALED :: VkFormat(25)
VK_FORMAT_R8G8B8_SSCALED :: VkFormat(26)
VK_FORMAT_R8G8B8_UINT :: VkFormat(27)
VK_FORMAT_R8G8B8_SINT :: VkFormat(28)
VK_FORMAT_B8G8R8_UNORM :: VkFormat(29)
VK_FORMAT_B8G8R8_SNORM :: VkFormat(30)
VK_FORMAT_R8G8B8A8_UNORM :: VkFormat(37)
VK_FORMAT_R8G8B8A8_SNORM :: VkFormat(38)
VK_FORMAT_R8G8B8A8_UINT :: VkFormat(41)
VK_FORMAT_R8G8B8A8_SINT :: VkFormat(42)
VK_FORMAT_B8G8R8A8_UNORM :: VkFormat(43)
VK_FORMAT_B8G8R8A8_SNORM :: VkFormat(44)
VK_FORMAT_B8G8R8A8_UINT :: VkFormat(47)
VK_FORMAT_B8G8R8A8_SINT :: VkFormat(48)
VK_FORMAT_A8B8G8R8_UNORM_PACK32 :: VkFormat(50)
VK_FORMAT_A8B8G8R8_SNORM_PACK32 :: VkFormat(51)
VK_FORMAT_A2R10G10B10_UNORM_PACK32 :: VkFormat(55)
VK_FORMAT_A2R10G10B10_SNORM_PACK32 :: VkFormat(56)
VK_FORMAT_A2R10G10B10_UINT_PACK32 :: VkFormat(57)
VK_FORMAT_A2R10G10B10_SINT_PACK32 :: VkFormat(58)
VK_FORMAT_A2B10G10R10_UNORM_PACK32 :: VkFormat(59)
VK_FORMAT_A2B10G10R10_SNORM_PACK32 :: VkFormat(60)
VK_FORMAT_A2B10G10R10_UINT_PACK32 :: VkFormat(61)
VK_FORMAT_A2B10G10R10_SINT_PACK32 :: VkFormat(62)

VK_IMAGE_ASPECT_COLOR_BIT :: u32(0x00000001)
VK_IMAGE_ASPECT_DEPTH_BIT :: u32(0x00000002)
VK_IMAGE_ASPECT_STENCIL_BIT :: u32(0x00000004)
VK_IMAGE_ASPECT_METADATA_BIT :: u32(0x00000008)

VK_COMPONENT_SWIZZLE_IDENTITY :: u32(0)
VK_COMPONENT_SWIZZLE_ZERO :: u32(1)
VK_COMPONENT_SWIZZLE_ONE :: u32(2)

VK_IMAGE_VIEW_TYPE_1D :: u32(0)
VK_IMAGE_VIEW_TYPE_2D :: u32(1)
VK_IMAGE_VIEW_TYPE_3D :: u32(2)
VK_IMAGE_VIEW_TYPE_CUBE :: u32(3)

VK_PRIMITIVE_TOPOLOGY_POINT_LIST :: u32(0)
VK_PRIMITIVE_TOPOLOGY_LINE_LIST :: u32(1)
VK_PRIMITIVE_TOPOLOGY_LINE_STRIP :: u32(2)
VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST :: u32(3)
VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP :: u32(4)
VK_PRIMITIVE_TOPOLOGY_TRIANGLE_FAN :: u32(5)
VK_PRIMITIVE_TOPOLOGY_LINE_LIST_WITH_ADJACENCY :: u32(8)
VK_PRIMITIVE_TOPOLOGY_LINE_STRIP_WITH_ADJACENCY :: u32(9)
VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST_WITH_ADJACENCY :: u32(10)
VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP_WITH_ADJACENCY :: u32(11)

VK_POLYGON_MODE_FILL :: u32(0x1b00)
VK_POLYGON_MODE_LINE :: u32(0x1b01)
VK_POLYGON_MODE_POINT :: u32(0x1b02)

VK_CULL_MODE_NONE :: u32(0)
VK_CULL_MODE_FRONT_BIT :: u32(0x00000001)
VK_CULL_MODE_BACK_BIT :: u32(0x00000002)
VK_CULL_MODE_FRONT_AND_BACK :: u32(0x00000003)

VK_FRONT_FACE_COUNTER_CLOCKWISE :: u32(0)
VK_FRONT_FACE_CLOCKWISE :: u32(1)

VK_VERTEX_INPUT_RATE_VERTEX :: u32(0)
VK_VERTEX_INPUT_RATE_INSTANCE :: u32(1)

VK_BLEND_FACTOR_ZERO :: u32(0)
VK_BLEND_FACTOR_ONE :: u32(1)
VK_BLEND_FACTOR_SRC_COLOR :: u32(2)
VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR :: u32(3)
VK_BLEND_FACTOR_DST_COLOR :: u32(4)
VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR :: u32(5)
VK_BLEND_FACTOR_SRC_ALPHA :: u32(6)
VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA :: u32(7)
VK_BLEND_FACTOR_DST_ALPHA :: u32(8)
VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA :: u32(9)
VK_BLEND_FACTOR_CONSTANT_COLOR :: u32(10)
VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR :: u32(11)
VK_BLEND_FACTOR_CONSTANT_ALPHA :: u32(12)
VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA :: u32(13)
VK_BLEND_FACTOR_SRC_ALPHA_SATURATE :: u32(14)

VK_BLEND_OP_ADD :: u32(0)
VK_BLEND_OP_SUBTRACT :: u32(1)
VK_BLEND_OP_REVERSE_SUBTRACT :: u32(2)
VK_BLEND_OP_MIN :: u32(3)
VK_BLEND_OP_MAX :: u32(4)

VK_LOGIC_OP_CLEAR :: u32(0)
VK_LOGIC_OP_AND :: u32(1)
VK_LOGIC_OP_AND_REVERSE :: u32(2)
VK_LOGIC_OP_COPY :: u32(3)
VK_LOGIC_OP_AND_INVERTED :: u32(4)
VK_LOGIC_OP_NO_OP :: u32(5)
VK_LOGIC_OP_XOR :: u32(6)
VK_LOGIC_OP_OR :: u32(7)
VK_LOGIC_OP_NOR :: u32(8)
VK_LOGIC_OP_EQUIVALENT :: u32(9)
VK_LOGIC_OP_INVERT :: u32(10)
VK_LOGIC_OP_OR_REVERSE :: u32(11)
VK_LOGIC_OP_COPY_INVERTED :: u32(12)
VK_LOGIC_OP_OR_INVERTED :: u32(13)
VK_LOGIC_OP_NAND :: u32(14)
VK_LOGIC_OP_SET :: u32(15)

VK_COMPARE_OP_NEVER :: u32(0)
VK_COMPARE_OP_LESS :: u32(1)
VK_COMPARE_OP_EQUAL :: u32(2)
VK_COMPARE_OP_LESS_OR_EQUAL :: u32(3)
VK_COMPARE_OP_GREATER :: u32(4)
VK_COMPARE_OP_NOT_EQUAL :: u32(5)
VK_COMPARE_OP_GREATER_OR_EQUAL :: u32(6)
VK_COMPARE_OP_ALWAYS :: u32(7)

VK_STENCIL_OP_KEEP :: u32(0)
VK_STENCIL_OP_ZERO :: u32(1)
VK_STENCIL_OP_REPLACE :: u32(2)
VK_STENCIL_OP_INCREMENT_AND_CLAMP :: u32(3)
VK_STENCIL_OP_DECREMENT_AND_CLAMP :: u32(4)
VK_STENCIL_OP_INVERT :: u32(5)
VK_STENCIL_OP_INCREMENT_AND_WRAP :: u32(6)
VK_STENCIL_OP_DECREMENT_AND_WRAP :: u32(7)

VK_SHADER_STAGE_VERTEX_BIT :: u32(0x00000001)
VK_SHADER_STAGE_FRAGMENT_BIT :: u32(0x00000020)

VK_PIPELINE_BIND_POINT_GRAPHICS :: u32(0)
VK_PIPELINE_BIND_POINT_COMPUTE :: u32(1)

VK_SAMPLE_COUNT_1_BIT :: u32(1)
VK_SAMPLE_COUNT_2_BIT :: u32(2)
VK_SAMPLE_COUNT_4_BIT :: u32(4)
VK_SAMPLE_COUNT_8_BIT :: u32(8)
VK_SAMPLE_COUNT_16_BIT :: u32(16)
VK_SAMPLE_COUNT_32_BIT :: u32(32)
VK_SAMPLE_COUNT_64_BIT :: u32(64)

VkOffset2D :: struct {
    x: i32
    y: i32
}

VkOffset3D :: struct {
    x: i32
    y: i32
    z: i32
}

VkExtent2D :: struct {
    width: u32
    height: u32
}

VkExtent3D :: struct {
    width: u32
    height: u32
    depth: u32
}

VkRect2D :: struct {
    offset: VkOffset2D
    extent: VkExtent2D
}

VkClearColorValue :: struct {
    float32: [4]f32
}

VkClearDepthStencilValue :: struct {
    depth: f32
    stencil: u32
}

VkClearValue :: struct {
    color: VkClearColorValue
    depthStencil: VkClearDepthStencilValue
}

VkViewport :: struct {
    x: f32
    y: f32
    width: f32
    height: f32
    min_depth: f32
    max_depth: f32
}

VkRect3D :: struct {
    offset: VkOffset3D
    extent: VkExtent3D
}

VkBufferImageCopy :: struct {
    bufferOffset: VkDeviceSize
    bufferRowLength: u32
    bufferImageHeight: u32
    imageSubresource: VkImageSubresourceLayers
    imageOffset: VkOffset3D
    imageExtent: VkExtent3D
}

VkBufferCopy :: struct {
    srcOffset: VkDeviceSize
    dstOffset: VkDeviceSize
    size: VkDeviceSize
}

VkImageSubresourceLayers :: struct {
    aspectMask: u32
    mipLevel: u32
    baseArrayLayer: u32
    layerCount: u32
}

VkImageSubresourceRange :: struct {
    aspectMask: u32
    baseMipLevel: u32
    levelCount: u32
    baseArrayLayer: u32
    layerCount: u32
}

VkImageCopy :: struct {
    srcSubresource: VkImageSubresourceLayers
    srcOffset: VkOffset3D
    dstSubresource: VkImageSubresourceLayers
    dstOffset: VkOffset3D
    extent: VkExtent3D
}

VkImageBlit :: struct {
    srcSubresource: VkImageSubresourceLayers
    srcOffsets: [2]VkOffset3D
    dstSubresource: VkImageSubresourceLayers
    dstOffsets: [2]VkOffset3D
}

VkMemoryBarrier :: struct {
    srcAccessMask: u32
    dstAccessMask: u32
}

VkImageMemoryBarrier :: struct {
    srcAccessMask: u32
    dstAccessMask: u32
    oldLayout: u32
    newLayout: u32
    srcQueueFamilyIndex: u32
    dstQueueFamilyIndex: u32
    image: VkImage
    subresourceRange: VkImageSubresourceRange
}

VkBufferMemoryBarrier :: struct {
    srcAccessMask: u32
    dstAccessMask: u32
    srcQueueFamilyIndex: u32
    dstQueueFamilyIndex: u32
    buffer: VkBuffer
    offset: VkDeviceSize
    size: VkDeviceSize
}

VkMemoryMappedMemoryRange :: struct {
    sType: u32
    pNext: rawptr
    memory: VkDeviceMemory
    offset: VkDeviceSize
    size: VkDeviceSize
}

VkSparseImageMemoryRequirements :: struct {
    formatProperties: VkSparseMemoryRequirements
    imageMipTailFirstLod: u32
    imageMipTailSize: VkDeviceSize
    imageMipTailOffset: VkDeviceSize
    imageMipTailStride: VkDeviceSize
}

VkSparseMemoryRequirements :: struct {
    formatMask: u32
    memTypeBits: u32
    size: VkDeviceSize
    alignment: VkDeviceSize
}

VkSparseImageMemoryRequirements2 :: struct {
    sType: u32
    pNext: rawptr
    memoryRequirements: VkSparseImageMemoryRequirements
}

VkSparseBufferMemoryRequirements :: struct {
    formatMask: u32
    memTypeBits: u32
    size: VkDeviceSize
    offset: VkDeviceSize
    stride: VkDeviceSize
}

VkSubresourceLayout :: struct {
    offset: VkDeviceSize
    size: VkDeviceSize
    rowPitch: VkDeviceSize
    arrayPitch: VkDeviceSize
    depthPitch: VkDeviceSize
}

VkMappedMemoryRange :: struct {
    sType: u32
    pNext: rawptr
    memory: VkDeviceMemory
    offset: VkDeviceSize
    size: VkDeviceSize
}

VkImageFormatProperties :: struct {
    maxArrayLayers: u32
    maxMipLevels: u32
    maxResourceSize: VkDeviceSize
    sampleCounts: u32
    extent: VkExtent3D
}

VkMemoryRequirements :: struct {
    alignment: VkDeviceSize
    size: VkDeviceSize
    memoryTypeBits: u32
}

VkMemoryAllocateInfo :: struct {
    sType: u32
    pNext: rawptr
    allocationSize: VkDeviceSize
    memoryTypeIndex: u32
}

VkMemoryWin32HandlePropertiesKHR :: struct {
    sType: u32
    pNext: rawptr
    memoryTypeBits: u32
    memoryTypeCount: u32
}

VkPhysicalDeviceMemoryProperties :: struct {
    memoryHeapCount: u32
    memoryHeaps: [16]VkMemoryHeap
    memoryTypeCount: u32
    memoryTypes: [32]VkMemoryType
}

VkMemoryHeap :: struct {
    flags: u32
    size: VkDeviceSize
}

VkMemoryType :: struct {
    heapIndex: u32
    propertyFlags: u32
}

VkPhysicalDeviceSparseProperties :: struct {
    residencyAlignedMipSize: bool
    residencyNonResidentStrict: bool
    residencyStandard2DBlockShape: bool
    residencyStandard3DBlockShape: bool
}

VkPhysicalDeviceProperties :: struct {
    apiVersion: u32
    driverVersion: u32
    vendorID: u32
    deviceID: u32
    deviceType: u32
    deviceName: [256]c.char
    driverName: [256]c.char
    driverName2: [256]c.char
    pipelineCacheUUID: [16]u8
    vendorName: [256]c.char
}

VkPhysicalDeviceFeatures :: struct {
    alphaToOne: bool
    depthBounds: bool
    depthClamp: bool
    discardRotatedAttachments: bool
    dualSrcBlend: bool
    fillModeNonSolid: bool
    fragmentStoresAndAtomics: bool
    fullDrawIndexUint32: bool
    geometryShader: bool
    imageCubeArray: bool
    independentBlend: bool
    largePoints: bool
    logicOp: bool
    multiDrawIndirect: bool
    multiViewport: bool
    occlusionQueryPrecise: bool
    pipelineStatisticsQuery: bool
    programmableSampleColors: bool
    robustBufferAccess: bool
    samplerAnisotropy: bool
    sampleRateShading: bool
    shaderClipDistance: bool
    shaderCullDistance: bool
    shaderFloat64: bool
    shaderGlobalLaneId: bool
    shaderInputOutputArray: bool
    shaderInt16: bool
    shaderInt64: bool
    shaderIntegerBase2: bool
    shaderSampledImageArrayDynamicIndexing: bool
    shaderStorageBufferArrayDynamicIndexing: bool
    shaderStorageImageArrayDynamicIndexing: bool
    shaderStorageImageMultisample: bool
    shaderStorageImageReadWithoutFormat: bool
    shaderStorageImageWriteWithoutFormat: bool
    shaderUniformBufferArrayDynamicIndexing: bool
    shaderVariableMultisampleRate: bool
    shaderViewportIndexLayer: bool
    tessellationShader: bool
    textureCompressionASTC_LDR: bool
    textureCompressionBC: bool
    textureCompressionETC2: bool
    vertexAttributeDivisor: bool
    vertexPipelineStoresAndAtomics: bool
    wideLines: bool
}

VkPhysicalDeviceFeatures2 :: struct {
    sType: u32
    pNext: rawptr
    features: VkPhysicalDeviceFeatures
}

VkFormatProperties :: struct {
    linearTilingFeatures: u32
    optimalTilingFeatures: u32
    bufferFeatures: u32
}

VkFormatProperties2 :: struct {
    sType: u32
    pNext: rawptr
    formatProperties: VkFormatProperties
}

VkPhysicalDeviceProperties2 :: struct {
    sType: u32
    pNext: rawptr
    properties: VkPhysicalDeviceProperties
}

VkQueueFamilyProperties :: struct {
    queueCount: u32
    queueFlags: u32
    timestampValidBits: u32
    minImageTransferGranularity: VkExtent3D
}

VkPhysicalDeviceLimits :: struct {
    bufferImageGranularity: u32
    maxBoundDescriptorSets: u32
    maxClipDistances: u32
    maxColorAttachments: u32
    maxCombinedClipAndCullDistances: u32
    maxComputeWorkGroupCount: [3]u32
    maxComputeWorkGroupInvocations: u32
    maxComputeWorkGroupSize: [3]u32
    maxCullDistances: u32
    maxDrawablePVRI: u32
    maxFragmentDualSrcAttachments: u32
    maxFragmentInputComponents: u32
    maxFragmentOutputAttachments: u32
    maxFragmentSampleWeightFilters: u32
    maxFramebufferHeight: u32
    maxFramebufferLayers: u32
    maxFramebufferWidth: u32
    maxImageArrayLayers: u32
    maxImageDimension1D: u32
    maxImageDimension2D: u32
    maxImageDimension3D: u32
    maxImageDimensionCube: u32
    maxLayersPerImageView: u32
    maxLineWidth: f32
    maxLineWidthRange: [2]f32
    maxMemoryAllocationCount: u32
    maxPushConstantsSize: u32
    maxSampleMaskWords: u32
    maxSamplerAllocationCount: u32
    maxSamplerAnisotropy: f32
    maxStorageBufferRange: u32
    maxStorageImageDimension1D: u32
    maxStorageImageDimension2D: u32
    maxStorageImageDimension3D: u32
    maxStorageImageDimensionCube: u32
    maxTexelBufferElements: u32
    maxTexelOffset: u32
    maxUniformBufferRange: u32
    maxVertexInputAttributeStride: u32
    maxVertexInputAttributes: u32
    maxVertexInputBindings: u32
    maxViewportDimensions: [2]u32
    minInterpolationOffset: f32
    minLineWidth: f32
    minLineWidthRange: [2]f32
    minMemoryMapAlignment: u32
    minStorageBufferOffsetAlignment: u32
    minTexelOffset: u32
    minUniformBufferOffsetAlignment: u32
    mipmapPrecisionBits: u32
    standardSampleLocations: bool
    subpixelPrecisionBits: u32
    subtexelPrecisionBits: u32
    tessellationDomainOrigin: u32
    timestampComputeAndGraphics: bool
    timestampPeriod: f32
    timestampValidBits: u32
    viewportBoundsRange: [2]f32
    viewportSubpixelBits: u32
}

VkSurfaceCapabilitiesKHR :: struct {
    minImageCount: u32
    maxImageCount: u32
    currentExtent: VkExtent2D
    minImageExtent: VkExtent2D
    maxImageExtent: VkExtent2D
    supportedCompositeAlpha: u32
    supportedTransforms: u32
    supportedUsageFlags: u32
}

VkSurfaceFormatKHR :: struct {
    format: VkFormat
    colorSpace: u32
}

VkLayerProperties :: struct {
    description: [256]c.char
    implementationVersion: u32
    specVersion: u32
    layerName: c.char
}

VkExtensionProperties :: struct {
    extensionName: c.char
    specVersion: u32
}

VkValidationFeaturesEXT :: struct {
    sType: u32
    pNext: rawptr
    validationFeatureCount: u32
    pValidationFeatures: ^u32
}

VkValidationFlagsEXT :: struct {
    sType: u32
    pNext: rawptr
    disabledValidationCheckCount: u32
    pDisabledValidationChecks: ^u32
}