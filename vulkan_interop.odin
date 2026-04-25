package game_desktop

foreign import vulkan {
    "system:vulkan",
    "system:vkSwapchain",
}

when ODIN_OS == "windows" {
    foreign import vulkan "system:vulkan-1.lib"
} else when ODIN_OS == "linux" {
    foreign import vulkan "system:vulkan"
} else when ODIN_OS == "darwin" {
    foreign import vulkan "system:vulkan"
}

import "core:c"

VkBool32 :: distinct u32
VkFlags :: distinct u32
VkDeviceSize :: distinct u64
VkSampleMask :: distinct u32
VkSystemAllocationScope :: distinct c.int
VkInternalAllocationScope :: distinct c.int
VkPhysicalDeviceType :: distinct u32
VkResult :: distinct i32
VkObjectType :: distinct u32
VkStructureType :: distinct u32
VkImageTiling :: distinct u32
VkImageLayout :: distinct u32
VkImageViewType :: distinct u32
VkCommandBufferLevel :: distinct u32
VkAttachmentDescriptionFlags :: distinct u32
VkAttachmentLoadOp :: distinct u32
VkAttachmentStoreOp :: distinct u32
VkFramebufferCreateFlags :: distinct u32
VkRenderPassCreateFlags :: distinct u32
VkPipelineCacheCreateFlags :: distinct u32
VkPipelineCreateFlags :: distinct u32
VkPipelineBindPoint :: distinct u32
VkCommandBufferResetFlags :: distinct u32
VkCommandPoolCreateFlags :: distinct u32
VkCommandBufferUsageFlags :: distinct u32
VkQueryControlFlags :: distinct u32
VkQueryResultFlags :: distinct u32
VkBufferCreateFlags :: distinct u32
VkBufferUsageFlags :: distinct u32
VkBufferViewCreateFlags :: distinct u32
VkImageCreateFlags :: distinct u32
VkImageUsageFlags :: distinct u32
VkImageViewCreateFlags :: distinct u32
VkShaderModuleCreateFlags :: distinct u32
VkPipelineShaderStageCreateFlags :: distinct u32
VkDescriptorSetLayoutCreateFlags :: distinct u32
VkDescriptorPoolCreateFlags :: distinct u32
VkDescriptorPoolResetFlags :: distinct u32
VkDeviceEventCreateFlags :: distinct u32
VkDisplayModeCreateFlags :: distinct u32
VkDisplayPlaneAlphaFlags :: distinct u32
VkDebugUtilsMessengerCreateFlags :: distinct u32
VkSamplerYcbcrModelConversion :: distinct u32
VkSamplerYcbcrRange :: distinct u32
VkChromaLocation :: distinct u32
VkComponentSwizzle :: distinct u32
VkCompositeAlphaFlags :: distinct u32
VkPresentModeKHR :: distinct u32
VkPresentModeFifoKHR :: distinct u32
VkPresentModeFifoRelaxedKHR :: distinct u32
VkPresentModeMailboxKHR :: distinct u32
VkPresentModeImmediateKHR :: distinct u32
VkColorSpaceKHR :: distinct u32
VkSwapchainCreateFlagsKHR :: distinct u32
VkSubpassContents :: distinct u32
VkAccessFlagBits :: distinct u32
VkAccessFlags :: distinct u32
VkImageAspectFlagBits :: distinct u32
VkImageAspectFlags :: distinct u32
VkFormatFeatureFlagBits :: distinct u32
VkFormatFeatureFlags :: distinct u32
VkShaderStageFlagBits :: distinct u32
VkShaderStageFlags :: distinct u32
VkVertexInputRate :: distinct u32
VkPrimitiveTopology :: distinct u32
VkPolygonMode :: distinct u32
VkCullModeFlagBits :: distinct u32
VkCullModeFlags :: distinct u32
VkFrontFace :: distinct u32
VkBlendFactor :: distinct u32
VkBlendOp :: distinct u32
VkCompareOp :: distinct u32
VkStencilOp :: distinct u32
VkLogicOp :: distinct u32
VkDynamicState :: distinct u32
VkPipelineStageFlagBits :: distinct u32
VkPipelineStageFlags :: distinct u32
VkQueueFlagBits :: distinct u32
VkQueueFlags :: distinct u32
VkMemoryPropertyFlagBits :: distinct u32
VkMemoryPropertyFlags :: distinct u32
VkMemoryHeapFlagBits :: distinct u32
VkMemoryHeapFlags :: distinct u32
VkQueueFamilyPropertiesFlags :: distinct u32

VK_MAKE_VERSION :: proc(major, minor, patch: u32) -> u32 {
    return ((major) << 22) | ((minor) << 12) | (patch)
}

VK_VERSION_MAJOR :: proc(version: u32) -> u32 { return (version) >> 22 }
VK_VERSION_MINOR :: proc(version: u32) -> u32 { return ((version) >> 12) & 0x3ff }
VK_VERSION_PATCH :: proc(version: u32) -> u32 { return (version) & 0xfff }

@(default_calling_convention="c")
foreign vulkan {
    vkEnumerateInstanceVersion :: proc(pApiVersion: ^u32) -> VkResult ---
    vkEnumerateInstanceExtensionProperties :: proc(pLayerName: ^c.char, pPropertyCount: ^u32, pProperties: ^VkExtensionProperties) -> VkResult ---
    vkEnumerateInstanceLayerProperties :: proc(pPropertyCount: ^u32, pProperties: ^VkLayerProperties) -> VkResult ---
    vkEnumeratePhysicalDevices :: proc(instance: VkInstance, pPhysicalDeviceCount: ^u32, pPhysicalDevices: ^VkPhysicalDevice) -> VkResult ---
    vkGetPhysicalDeviceFeatures2 :: proc(physicalDevice: VkPhysicalDevice, pFeatures: ^VkPhysicalDeviceFeatures2) ---
    vkGetPhysicalDeviceFormatInfo2 :: proc(physicalDevice: VkPhysicalDevice, format: VkFormat, pFormatInfo: ^VkFormatProperties2) ---
    vkGetPhysicalDeviceProperties2 :: proc(physicalDevice: VkPhysicalDevice, pProperties: ^VkPhysicalDeviceProperties2) ---
    vkDestroyInstance :: proc(instance: VkInstance, pAllocator: ^VkAllocationCallbacks) ---
    vkGetPhysicalDeviceFeatures :: proc(physicalDevice: VkPhysicalDevice, pFeatures: ^VkPhysicalDeviceFeatures) ---
    vkGetPhysicalDeviceFormatProperties :: proc(physicalDevice: VkPhysicalDevice, format: VkFormat, pFormatProperties: ^VkFormatProperties) ---
    vkGetPhysicalDeviceMemoryProperties :: proc(physicalDevice: VkPhysicalDevice, pMemoryProperties: ^VkPhysicalDeviceMemoryProperties) ---
    vkGetPhysicalDeviceProperties :: proc(physicalDevice: VkPhysicalDevice, pProperties: ^VkPhysicalDeviceProperties) ---
    vkGetPhysicalDeviceQueueFamilyProperties :: proc(physicalDevice: VkPhysicalDevice, pQueueFamilyPropertyCount: ^u32, pQueueFamilyProperties: ^VkQueueFamilyProperties) ---
    vkGetPhysicalDeviceQueueFamilyPropertiesCount :: proc(physicalDevice: VkPhysicalDevice, pQueueFamilyPropertyCount: ^u32) -> VkResult ---
    vkCreateAndroidSurfaceKHR :: proc(instance: VkInstance, pCreateInfo: ^VkAndroidSurfaceCreateInfoKHR, pAllocator: ^VkAllocationCallbacks, pSurface: ^VkSurfaceKHR) -> VkResult ---
    vkCreateDisplayPlaneSurfaceKHR :: proc(instance: VkInstance, pCreateInfo: ^VkDisplayPlaneSurfaceCreateInfoKHR, pAllocator: ^VkAllocationCallbacks, pSurface: ^VkSurfaceKHR) -> VkResult ---
    vkCreateHeadlessSurfaceEXT :: proc(instance: VkInstance, pCreateInfo: ^VkHeadlessSurfaceCreateInfoEXT, pAllocator: ^VkAllocationCallbacks, pSurface: ^VkSurfaceKHR) -> VkResult ---
    vkCreateIOSSurfaceMVK :: proc(instance: VkInstance, pCreateInfo: ^VkIOSSurfaceCreateInfoMVK, pAllocator: ^VkAllocationCallbacks, pSurface: ^VkSurfaceKHR) -> VkResult ---
    vkCreateMacOSSurfaceMVK :: proc(instance: VkInstance, pCreateInfo: ^VkMacOSSurfaceCreateInfoMVK, pAllocator: ^VkAllocationCallbacks, pSurface: ^VkSurfaceKHR) -> VkResult ---
    vkDestroySurfaceKHR :: proc(instance: VkInstance, surface: VkSurfaceKHR, pAllocator: ^VkAllocationCallbacks) ---
    vkGetPhysicalDeviceSurfaceSupportKHR :: proc(physicalDevice: VkPhysicalDevice, queueFamilyIndex: u32, surface: VkSurfaceKHR, pSupported: ^VkBool32) -> VkResult ---
    vkGetPhysicalDeviceSurfaceCapabilitiesKHR :: proc(physicalDevice: VkPhysicalDevice, surface: VkSurfaceKHR, pSurfaceCapabilities: ^VkSurfaceCapabilitiesKHR) -> VkResult ---
    vkGetPhysicalDeviceSurfaceFormatsKHR :: proc(physicalDevice: VkPhysicalDevice, surface: VkSurfaceKHR, pSurfaceFormatCount: ^u32, pSurfaceFormats: ^VkSurfaceFormatKHR) -> VkResult ---
    vkGetPhysicalDeviceSurfacePresentModesKHR :: proc(physicalDevice: VkPhysicalDevice, surface: VkSurfaceKHR, pPresentModeCount: ^u32, pPresentModes: ^VkPresentModeKHR) -> VkResult ---
    vkGetPhysicalDeviceWin32PresentationSupportKHR :: proc(physicalDevice: VkPhysicalDevice, queueFamilyIndex: u32) -> VkBool32 ---
    vkGetPhysicalDeviceXlibPresentationSupportKHR :: proc(physicalDevice: VkPhysicalDevice, queueFamilyIndex: u32, display: Xlib.DisplayPointer, visualID: XVisualID) -> VkBool32 ---
    vkGetPhysicalDeviceXcbPresentationSupportKHR :: proc(physicalDevice: VkPhysicalDevice, queueFamilyIndex: u32, connection: Xcb.Connection, visualID: Xcb.VisualID) -> VkBool32 ---
    vkDestroyDevice :: proc(device: VkDevice, pAllocator: ^VkAllocationCallbacks) ---
    vkGetDeviceQueue :: proc(device: VkDevice, queueFamilyIndex: u32, queueIndex: u32, pQueue: ^VkQueue) ---
    vkQueueSubmit :: proc(queue: VkQueue, submitCount: u32, pSubmits: ^VkSubmitInfo, fence: VkFence) -> VkResult ---
    vkQueueWaitIdle :: proc(queue: VkQueue) -> VkResult ---
    vkDeviceWaitIdle :: proc(device: VkDevice) -> VkResult ---
    vkAllocateMemory :: proc(device: VkDevice, pAllocateInfo: ^VkMemoryAllocateInfo, pAllocator: ^VkAllocationCallbacks, pMemory: ^VkDeviceMemory) -> VkResult ---
    vkFreeMemory :: proc(device: VkDevice, memory: VkDeviceMemory, pAllocator: ^VkAllocationCallbacks) ---
    vkMapMemory :: proc(device: VkDevice, memory: VkDeviceMemory, offset: VkDeviceSize, size: VkDeviceSize, flags: VkMemoryMapFlags, ppData: ^rawptr) -> VkResult ---
    vkUnmapMemory :: proc(device: VkDevice, memory: VkDeviceMemory) ---
    vkFlushMappedMemoryRanges :: proc(device: VkDevice, memoryRangeCount: u32, pMemoryRanges: ^VkMappedMemoryRange) -> VkResult ---
    vkInvalidateMappedMemoryRanges :: proc(device: VkDevice, memoryRangeCount: u32, pMemoryRanges: ^VkMappedMemoryRange) -> VkResult ---
    vkBindBufferMemory :: proc(device: VkDevice, buffer: VkBuffer, memory: VkDeviceMemory, memoryOffset: VkDeviceSize) -> VkResult ---
    vkBindImageMemory :: proc(device: VkDevice, image: VkImage, memory: VkDeviceMemory, memoryOffset: VkDeviceSize) -> VkResult ---
    vkGetBufferMemoryRequirements :: proc(device: VkDevice, buffer: VkBuffer, pMemoryRequirements: ^VkMemoryRequirements) ---
    vkGetImageMemoryRequirements :: proc(device: VkDevice, image: VkImage, pMemoryRequirements: ^VkMemoryRequirements) ---
    vkGetImageSparseMemoryRequirements :: proc(device: VkDevice, image: VkImage, pSparseMemoryRequirementCount: ^u32, pSparseMemoryRequirements: ^VkSparseImageMemoryRequirements2) ---
    vkGetPhysicalDeviceSparseMemoryRequirements :: proc(physicalDevice: VkPhysicalDevice, pSparseMemoryRequirementCount: ^u32, pSparseMemoryRequirements: ^VkSparseImageMemoryRequirements2) ---
    vkCreateBuffer :: proc(device: VkDevice, pCreateInfo: ^VkBufferCreateInfo, pAllocator: ^VkAllocationCallbacks, pBuffer: ^VkBuffer) -> VkResult ---
    vkDestroyBuffer :: proc(device: VkDevice, buffer: VkBuffer, pAllocator: ^VkAllocationCallbacks) ---
    vkCreateBufferView :: proc(device: VkDevice, pCreateInfo: ^VkBufferViewCreateInfo, pAllocator: ^VkAllocationCallbacks, pBufferView: ^VkBufferView) -> VkResult ---
    vkDestroyBufferView :: proc(device: VkDevice, bufferView: VkBufferView, pAllocator: ^VkAllocationCallbacks) ---
    vkCreateImage :: proc(device: VkDevice, pCreateInfo: ^VkImageCreateInfo, pAllocator: ^VkAllocationCallbacks, pImage: ^VkImage) -> VkResult ---
    vkDestroyImage :: proc(device: VkDevice, image: VkImage, pAllocator: ^VkAllocationCallbacks) ---
    vkGetImageSubresourceLayout :: proc(device: VkDevice, image: VkImage, pSubresource: ^VkImageSubresource, pLayout: ^VkSubresourceLayout) ---
    vkCreateImageView :: proc(device: VkDevice, pCreateInfo: ^VkImageViewCreateInfo, pAllocator: ^VkAllocationCallbacks, pView: ^VkImageView) -> VkResult ---
    vkDestroyImageView :: proc(device: VkDevice, imageView: VkImageView, pAllocator: ^VkAllocationCallbacks) ---
    vkCreateSampler :: proc(device: VkDevice, pCreateInfo: ^VkSamplerCreateInfo, pAllocator: ^VkAllocationCallbacks, pSampler: ^VkSampler) -> VkResult ---
    vkDestroySampler :: proc(device: VkDevice, sampler: VkSampler, pAllocator: ^VkAllocationCallbacks) ---
    vkCreateDescriptorSetLayout :: proc(device: VkDevice, pCreateInfo: ^VkDescriptorSetLayoutCreateInfo, pAllocator: ^VkAllocationCallbacks, pSetLayout: ^VkDescriptorSetLayout) -> VkResult ---
    vkDestroyDescriptorSetLayout :: proc(device: VkDevice, descriptorSetLayout: VkDescriptorSetLayout, pAllocator: ^VkAllocationCallbacks) ---
    vkCreateDescriptorPool :: proc(device: VkDevice, pCreateInfo: ^VkDescriptorPoolCreateInfo, pAllocator: ^VkAllocationCallbacks, pDescriptorPool: ^VkDescriptorPool) -> VkResult ---
    vkDestroyDescriptorPool :: proc(device: VkDevice, descriptorPool: VkDescriptorPool, pAllocator: ^VkAllocationCallbacks) ---
    vkResetDescriptorPool :: proc(device: VkDevice, descriptorPool: VkDescriptorPool, flags: VkDescriptorPoolResetFlags) -> VkResult ---
    vkAllocateDescriptorSets :: proc(device: VkDevice, pAllocateInfo: ^VkDescriptorSetAllocateInfo, pDescriptorSets: ^VkDescriptorSet) -> VkResult ---
    vkFreeDescriptorSets :: proc(device: VkDevice, descriptorPool: VkDescriptorPool, descriptorSetCount: u32, pDescriptorSets: ^VkDescriptorSet) -> VkResult ---
    vkUpdateDescriptorSets :: proc(device: VkDevice, descriptorWriteCount: u32, pDescriptorWrites: ^VkWriteDescriptorSet, descriptorCopyCount: u32, pDescriptorCopies: ^VkCopyDescriptorSet) ---
    vkCreateFramebuffer :: proc(device: VkDevice, pCreateInfo: ^VkFramebufferCreateInfo, pAllocator: ^VkAllocationCallbacks, pFramebuffer: ^VkFramebuffer) -> VkResult ---
    vkDestroyFramebuffer :: proc(device: VkDevice, framebuffer: VkFramebuffer, pAllocator: ^VkAllocationCallbacks) ---
    vkCreateRenderPass :: proc(device: VkDevice, pCreateInfo: ^VkRenderPassCreateInfo, pAllocator: ^VkAllocationCallbacks, pRenderPass: ^VkRenderPass) -> VkResult ---
    vkDestroyRenderPass :: proc(device: VkDevice, renderPass: VkRenderPass, pAllocator: ^VkAllocationCallbacks) ---
    vkGetRenderAreaGranularity :: proc(device: VkDevice, renderPass: VkRenderPass, pGranularity: ^VkExtent2D) ---
    vkCreateCommandPool :: proc(device: VkDevice, pCreateInfo: ^VkCommandPoolCreateInfo, pAllocator: ^VkAllocationCallbacks, pCommandPool: ^VkCommandPool) -> VkResult ---
    vkDestroyCommandPool :: proc(device: VkDevice, commandPool: VkCommandPool, pAllocator: ^VkAllocationCallbacks) ---
    vkResetCommandPool :: proc(device: VkDevice, commandPool: VkCommandPool, flags: VkCommandPoolResetFlags) -> VkResult ---
    vkAllocateCommandBuffers :: proc(device: VkDevice, pAllocateInfo: ^VkCommandBufferAllocateInfo, pCommandBuffers: ^VkCommandBuffer) -> VkResult ---
    vkFreeCommandBuffers :: proc(device: VkDevice, commandPool: VkCommandPool, commandBufferCount: u32, pCommandBuffers: ^VkCommandBuffer) ---
    vkBeginCommandBuffer :: proc(commandBuffer: VkCommandBuffer, pBeginInfo: ^VkCommandBufferBeginInfo) -> VkResult ---
    vkEndCommandBuffer :: proc(commandBuffer: VkCommandBuffer) -> VkResult ---
    vkResetCommandBuffer :: proc(commandBuffer: VkCommandBuffer, flags: VkCommandBufferResetFlags) -> VkResult ---
    vkCmdBindPipeline :: proc(commandBuffer: VkCommandBuffer, pipelineBindPoint: VkPipelineBindPoint, pipeline: VkPipeline) ---
    vkCmdSetViewport :: proc(commandBuffer: VkCommandBuffer, firstViewport: u32, viewportCount: u32, pViewports: ^VkViewport) ---
    vkCmdSetScissor :: proc(commandBuffer: VkCommandBuffer, firstScissor: u32, scissorCount: u32, pScissors: ^VkRect2D) ---
    vkCmdSetLineWidth :: proc(commandBuffer: VkCommandBuffer, lineWidth: f32) ---
    vkCmdSetDepthBias :: proc(commandBuffer: VkCommandBuffer, depthBiasConstantFactor: f32, depthBiasClamp: f32, depthBiasSlopeFactor: f32) ---
    vkCmdSetBlendConstants :: proc(commandBuffer: VkCommandBuffer, blendConstants: [4]f32) ---
    vkCmdSetDepthBounds :: proc(commandBuffer: VkCommandBuffer, minDepthBounds: f32, maxDepthBounds: f32) ---
    vkCmdSetStencilCompareMask :: proc(commandBuffer: VkCommandBuffer, faceMask: VkStencilFaceFlags, compareMask: u32) ---
    vkCmdSetStencilWriteMask :: proc(commandBuffer: VkCommandBuffer, faceMask: VkStencilFaceFlags, writeMask: u32) ---
    vkCmdSetStencilReference :: proc(commandBuffer: VkCommandBuffer, faceMask: VkStencilFaceFlags, reference: u32) ---
    vkCmdBindDescriptorSets :: proc(commandBuffer: VkCommandBuffer, pipelineBindPoint: VkPipelineBindPoint, layout: VkPipelineLayout, firstSet: u32, descriptorSetCount: u32, pDescriptorSets: ^VkDescriptorSet, dynamicOffsetCount: u32, pDynamicOffsets: ^u32) ---
    vkCmdBindIndexBuffer :: proc(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: VkDeviceSize, indexType: VkIndexType) ---
    vkCmdBindVertexBuffers :: proc(commandBuffer: VkCommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: ^VkBuffer, pOffsets: ^VkDeviceSize) ---
    vkCmdDraw :: proc(commandBuffer: VkCommandBuffer, vertexCount: u32, instanceCount: u32, firstVertex: u32, firstInstance: u32) ---
    vkCmdDrawIndexed :: proc(commandBuffer: VkCommandBuffer, indexCount: u32, instanceCount: u32, firstIndex: u32, vertexOffset: i32, firstInstance: u32) ---
    vkCmdDrawIndirect :: proc(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: VkDeviceSize, drawCount: u32, stride: u32) ---
    vkCmdDrawIndexedIndirect :: proc(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: VkDeviceSize, drawCount: u32, stride: u32) ---
    vkCmdCopyBuffer :: proc(commandBuffer: VkCommandBuffer, srcBuffer: VkBuffer, dstBuffer: VkBuffer, regionCount: u32, pRegions: ^VkBufferCopy) ---
    vkCmdCopyImage :: proc(commandBuffer: VkCommandBuffer, srcImage: VkImage, srcImageLayout: VkImageLayout, dstImage: VkImage, dstImageLayout: VkImageLayout, regionCount: u32, pRegions: ^VkImageCopy) ---
    vkCmdBlitImage :: proc(commandBuffer: VkCommandBuffer, srcImage: VkImage, srcImageLayout: VkImageLayout, dstImage: VkImage, dstImageLayout: VkImageLayout, regionCount: u32, pRegions: ^VkImageBlit, filter: VkFilter) ---
    vkCmdCopyBufferToImage :: proc(commandBuffer: VkCommandBuffer, srcBuffer: VkBuffer, dstImage: VkImage, dstImageLayout: VkImageLayout, regionCount: u32, pRegions: ^VkBufferImageCopy) ---
    vkCmdCopyImageToBuffer :: proc(commandBuffer: VkCommandBuffer, srcImage: VkImage, srcImageLayout: VkImageLayout, dstBuffer: VkBuffer, regionCount: u32, pRegions: ^VkBufferImageCopy) ---
    vkCmdUpdateBuffer :: proc(commandBuffer: VkCommandBuffer, dstBuffer: VkBuffer, dstOffset: VkDeviceSize, dataSize: VkDeviceSize, pData: ^u32) ---
    vkCmdFillBuffer :: proc(commandBuffer: VkCommandBuffer, dstBuffer: VkBuffer, dstOffset: VkDeviceSize, size: VkDeviceSize, data: u32) ---
    vkCmdClearColorImage :: proc(commandBuffer: VkCommandImage, image: VkImage, imageLayout: VkImageLayout, pColor: ^VkClearColorValue, rangeCount: u32, pRanges: ^VkImageSubresourceRange) ---
    vkCmdClearDepthStencilImage :: proc(commandBuffer: VkCommandBuffer, image: VkImage, imageLayout: VkImageLayout, pDepthStencil: ^VkClearDepthStencilValue, rangeCount: u32, pRanges: ^VkImageSubresourceRange) ---
    vkCmdClearAttachments :: proc(commandBuffer: VkCommandBuffer, attachmentCount: u32, pAttachments: ^VkClearAttachment, rectCount: u32, pRects: ^VkClearRect) ---
    vkCmdResolveImage :: proc(commandBuffer: VkCommandBuffer, srcImage: VkImage, srcImageLayout: VkImageLayout, dstImage: VkImage, dstImageLayout: VkImageLayout, regionCount: u32, pRegions: ^VkResolveImageRegion) ---
    vkCmdSetEvent :: proc(commandBuffer: VkCommandBuffer, event: VkEvent, stageMask: VkPipelineStageFlags) ---
    vkCmdResetEvent :: proc(commandBuffer: VkCommandBuffer, event: VkEvent, stageMask: VkPipelineStageFlags) ---
    vkCmdWaitEvents :: proc(commandBuffer: VkCommandBuffer, eventCount: u32, pEvents: ^VkEvent, srcStageMask: VkPipelineStageFlags, dstStageMask: VkPipelineStageFlags, memoryBarrierCount: u32, pMemoryBarriers: ^VkMemoryBarrier, bufferMemoryBarrierCount: u32, pBufferMemoryBarriers: ^VkBufferMemoryBarrier, imageMemoryBarrierCount: u32, pImageMemoryBarriers: ^VkImageMemoryBarrier) ---
    vkCmdPipelineBarrier :: proc(commandBuffer: VkCommandBuffer, srcStageMask: VkPipelineStageFlags, dstStageMask: VkPipelineStageFlags, dependencyFlags: VkDependencyFlags, memoryBarrierCount: u32, pMemoryBarriers: ^VkMemoryBarrier, bufferMemoryBarrierCount: u32, pBufferMemoryBarriers: ^VkBufferMemoryBarrier, imageMemoryBarrierCount: u32, pImageMemoryBarriers: ^VkImageMemoryBarrier) ---
    vkCmdBeginQuery :: proc(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, query: u32, flags: VkQueryControlFlags) ---
    vkCmdEndQuery :: proc(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, query: u32) ---
    vkCmdResetQueryPool :: proc(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, firstQuery: u32, queryCount: u32) ---
    vkCmdWriteTimestamp :: proc(commandBuffer: VkCommandBuffer, pipelineStage: VkPipelineStageFlags, queryPool: VkQueryPool, query: u32) ---
    vkCmdCopyQueryPoolResults :: proc(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, firstQuery: u32, queryCount: u32, dstBuffer: VkBuffer, dstOffset: VkDeviceSize, stride: VkDeviceSize, flags: VkQueryResultFlags) ---
    vkCmdPushConstants :: proc(commandBuffer: VkCommandBuffer, layout: VkPipelineLayout, stageFlags: VkShaderStageFlags, offset: u32, size: u32, pValues: ^u32) ---
    vkCmdBeginRenderPass :: proc(commandBuffer: VkCommandBuffer, pRenderPassBegin: ^VkRenderPassBeginInfo, contents: VkSubpassContents) ---
    vkCmdNextSubpass :: proc(commandBuffer: VkCommandBuffer, contents: VkSubpassContents) ---
    vkCmdEndRenderPass :: proc(commandBuffer: VkCommandBuffer) ---
    vkCmdExecuteCommands :: proc(commandBuffer: VkCommandBuffer, commandBufferCount: u32, pCommandBuffers: ^VkCommandBuffer) ---
    vkCreateSemaphore :: proc(device: VkDevice, pCreateInfo: ^VkSemaphoreCreateInfo, pAllocator: ^VkAllocationCallbacks, pSemaphore: ^VkSemaphore) -> VkResult ---
    vkDestroySemaphore :: proc(device: VkDevice, semaphore: VkSemaphore, pAllocator: ^VkAllocationCallbacks) ---
    vkCreateFence :: proc(device: VkDevice, pCreateInfo: ^VkFenceCreateInfo, pAllocator: ^VkAllocationCallbacks, pFence: ^VkFence) -> VkResult ---
    vkDestroyFence :: proc(device: VkDevice, fence: VkFence, pAllocator: ^VkAllocationCallbacks) ---
    vkResetFences :: proc(device: VkDevice, fenceCount: u32, pFences: ^VkFence) -> VkResult ---
    vkGetFenceStatus :: proc(device: VkDevice, fence: VkFence) -> VkResult ---
    vkWaitForFences :: proc(device: VkDevice, fenceCount: u32, pFences: ^VkFence, waitAll: VkBool32, timeout: u64) -> VkResult ---
    vkCreateEvent :: proc(device: VkDevice, pCreateInfo: ^VkEventCreateInfo, pAllocator: ^VkAllocationCallbacks, pEvent: ^VkEvent) -> VkResult ---
    vkDestroyEvent :: proc(device: VkDevice, event: VkEvent, pAllocator: ^VkAllocationCallbacks) ---
    vkGetEventStatus :: proc(device: VkDevice, event: VkEvent) -> VkResult ---
    vkSetEvent :: proc(device: VkDevice, event: VkEvent) -> VkResult ---
    vkResetEvent :: proc(device: VkDevice, event: VkEvent) -> VkResult ---
    vkCreateQueryPool :: proc(device: VkDevice, pCreateInfo: ^VkQueryPoolCreateInfo, pAllocator: ^VkAllocationCallbacks, pQueryPool: ^VkQueryPool) -> VkResult ---
    vkDestroyQueryPool :: proc(device: VkDevice, queryPool: VkQueryPool, pAllocator: ^VkAllocationCallbacks) ---
    vkGetQueryPoolResults :: proc(device: VkDevice, queryPool: VkQueryPool, firstQuery: u32, queryCount: u32, dataSize: c.size_t, pData: rawptr, stride: VkDeviceSize, flags: VkQueryResultFlags) -> VkResult ---
    vkCreatePipelineCache :: proc(device: VkDevice, pCreateInfo: ^VkPipelineCacheCreateInfo, pAllocator: ^VkAllocationCallbacks, pPipelineCache: ^VkPipelineCache) -> VkResult ---
    vkDestroyPipelineCache :: proc(device: VkDevice, pipelineCache: VkPipelineCache, pAllocator: ^VkAllocationCallbacks) ---
    vkGetPipelineCacheData :: proc(device: VkDevice, pipelineCache: VkPipelineCache, pDataSize: ^c.size_t, pData: rawptr) -> VkResult ---
    vkMergePipelineCaches :: proc(device: VkDevice, dstCache: VkPipelineCache, srcCacheCount: u32, pSrcCaches: ^VkPipelineCache) -> VkResult ---
    vkCreateGraphicsPipelines :: proc(device: VkDevice, pipelineCache: VkPipelineCache, createInfoCount: i32, pCreateInfos: ^VkGraphicsPipelineCreateInfo, pAllocator: ^VkAllocationCallbacks, pPipelines: ^VkPipeline) -> VkResult ---
    vkCreateComputePipelines :: proc(device: VkDevice, pipelineCache: VkPipelineCache, createInfoCount: i32, pCreateInfos: ^VkComputePipelineCreateInfo, pAllocator: ^VkAllocationCallbacks, pPipelines: ^VkPipeline) -> VkResult ---
    vkDestroyPipeline :: proc(device: VkDevice, pipeline: VkPipeline, pAllocator: ^VkAllocationCallbacks) ---
    vkCreatePipelineLayout :: proc(device: VkDevice, pCreateInfo: ^VkPipelineLayoutCreateInfo, pAllocator: ^VkAllocationCallbacks, pPipelineLayout: ^VkPipelineLayout) -> VkResult ---
    vkDestroyPipelineLayout :: proc(device: VkDevice, pipelineLayout: VkPipelineLayout, pAllocator: ^VkAllocationCallbacks) ---
    vkGetDeviceQueue2 :: proc(device: VkDevice, pQueueInfo: ^VkDeviceQueueInfo2, pQueue: ^VkQueue) ---
}

@(default_calling_convention="c")
foreign vulkan {
    vkEnumerateInstanceExtensionProperties :: proc(pLayerName: ^c.char, pPropertyCount: ^u32, pProperties: ^VkExtensionProperties) -> VkResult ---
    vkEnumerateInstanceLayerProperties :: proc(pPropertyCount: ^u32, pProperties: ^VkLayerProperties) -> VkResult ---
    vkCreateInstance :: proc(pCreateInfo: ^VkInstanceCreateInfo, pAllocator: ^VkAllocationCallbacks, pInstance: ^VkInstance) -> VkResult ---
    vkGetInstanceProcAddr :: proc(instance: VkInstance, pName: ^c.char) -> rawptr ---
    vkEnumeratePhysicalDeviceGroups :: proc(instance: VkInstance, pPhysicalDeviceGroupCount: ^u32, pPhysicalDeviceGroups: ^VkPhysicalDeviceGroupProperties) -> VkResult ---
}

VK_KHR_xlib_surface :: "VK_KHR_xlib_surface"
VK_KHR_xcb_surface :: "VK_KHR_xcb_surface"
VK_KHR_wayland_surface :: "VK_KHR_wayland_surface"
VK_KHR_win32_surface :: "VK_KHR_win32_surface"
VK_KHR_android_surface :: "VK_KHR_android_surface"
VK_KHR_surface :: "VK_KHR_surface"
VK_EXT_headless_surface :: "VK_EXT_headless_surface"

when ODIN_OS == "linux" {
    @(default_calling_convention="c")
    foreign vulkan {
        vkCreateXlibSurfaceKHR :: proc(instance: VkInstance, pCreateInfo: ^VkXlibSurfaceCreateInfoKHR, pAllocator: ^VkAllocationCallbacks, pSurface: ^VkSurfaceKHR) -> VkResult ---
        vkGetPhysicalDeviceXlibPresentationSupportKHR :: proc(physicalDevice: VkPhysicalDevice, queueFamilyIndex: u32, display: rawptr, visualID: u64) -> VkBool32 ---
        vkCreateXcbSurfaceKHR :: proc(instance: VkInstance, pCreateInfo: ^VkXcbSurfaceCreateInfoKHR, pAllocator: ^VkAllocationCallbacks, pSurface: ^VkSurfaceKHR) -> VkResult ---
        vkGetPhysicalDeviceXcbPresentationSupportKHR :: proc(physicalDevice: VkPhysicalDevice, queueFamilyIndex: u32, connection: rawptr, visualID: u64) -> VkBool32 ---
        vkCreateWaylandSurfaceKHR :: proc(instance: VkInstance, pCreateInfo: ^VkWaylandSurfaceCreateInfoKHR, pAllocator: ^VkAllocationCallbacks, pSurface: ^VkSurfaceKHR) -> VkResult ---
        vkGetPhysicalDeviceWaylandPresentationSupportKHR :: proc(physicalDevice: VkPhysicalDevice, queueFamilyIndex: u32, display: rawptr) -> VkBool32 ---
    }
}

when ODIN_OS == "windows" {
    @(default_calling_convention="c")
    foreign vulkan {
        vkCreateWin32SurfaceKHR :: proc(instance: VkInstance, pCreateInfo: ^VkWin32SurfaceCreateInfoKHR, pAllocator: ^VkAllocationCallbacks, pSurface: ^VkSurfaceKHR) -> VkResult ---
        vkGetPhysicalDeviceWin32PresentationSupportKHR :: proc(physicalDevice: VkPhysicalDevice, queueFamilyIndex: u32) -> VkBool32 ---
        vkGetMemoryWin32HandlePropertiesKHR :: proc(device: VkDevice, memoryType: VkMemoryPropertyFlags, handle: rawptr, pMemoryWin32HandleProperties: ^VkMemoryWin32HandlePropertiesKHR) ---
        vkGetMemoryWin32HandleNV :: proc(device: VkDevice, memory: VkDeviceMemory, handleType: u32, pHandle: ^rawptr) ---
    }
}

Xlib :: struct {
    DisplayPointer: rawptr,
    VisualID: u64,
}

Xlib.DisplayPointer :: distinct rawptr
Xlib.VisualID :: distinct u64
Xcb.Connection :: distinct rawptr
Xcb.VisualID :: distinct u64
Xcb.Window :: distinct u64
Xcb.Atom :: distinct u64