package game_desktop

import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import "core:strings"
import "camera"

VulkanBackend :: struct {
    initialized: bool
    
    instance: VkInstance
    physical_device: VkPhysicalDevice
    device: VkDevice
    
    graphics_queue: VkQueue
    present_queue: VkQueue
    
    surface: VkSurfaceKHR
    swapchain: VkSwapchainKHR
    swapchain_images: []VkImage
    swapchain_image_views: []VkImageView
    swapchain_image_format: VkFormat
    swapchain_extent: VkExtent2D
    swapchain_framebuffers: []VkFramebuffer
    
    render_pass: VkRenderPass
    pipeline: VkPipeline
    pipeline_layout: VkPipelineLayout
    
    descriptor_set_layout: VkDescriptorSetLayout
    descriptor_pool: VkDescriptorSet
    descriptor_sets: []VkDescriptorSet
    
    command_pool: VkCommandPool
    command_buffers: []VkCommandBuffer
    
    depth_image: VkImage
    depth_image_memory: VkDeviceMemory
    depth_image_view: VkImageView
    
    camera: camera.Camera
    camera_input: camera.CameraInputState
    
    meshes: []VulkanMesh
    textures: []VulkanTexture
    
    current_frame: int
    max_frames_in_flight: int
    in_flight_fences: []VkFence
    image_available_semaphores: []VkSemaphore
    render_finished_semaphores: []VkSemaphore
    
    clear_color: camera.Vec4
    clear_depth: f32
    
    present_mode: u32
    vsync: bool
}

VkInstance :: struct {
    handle: u64
}

VkPhysicalDevice :: struct {
    handle: u64
}

VkDevice :: struct {
    handle: u64
}

VkQueue :: struct {
    handle: u64
}

VkSurfaceKHR :: struct {
    handle: u64
}

VkSwapchainKHR :: struct {
    handle: u64
}

VkImage :: struct {
    handle: u64
}

VkImageView :: struct {
    handle: u64
}

VkFramebuffer :: struct {
    handle: u64
}

VkRenderPass :: struct {
    handle: u64
}

VkPipeline :: struct {
    handle: u64
}

VkPipelineLayout :: struct {
    handle: u64
}

VkDescriptorSetLayout :: struct {
    handle: u64
}

VkDescriptorSet :: struct {
    handle: u64
}

VkDescriptorPool :: struct {
    handle: u64
}

VkCommandPool :: struct {
    handle: u64
}

VkCommandBuffer :: struct {
    handle: u64
}

VkDeviceMemory :: struct {
    handle: u64
}

VkFence :: struct {
    handle: u64
}

VkSemaphore :: struct {
    handle: u64
}

VkFormat :: enum {
    undefined,
    r8g8b8a8_unorm,
    b8g8r8a8_unorm,
    r8g8b8_unorm,
    b8g8r8_unorm,
    r5g6b5_unorm_pack16,
    b5g6r5_unorm_pack16,
    d16_unorm,
    x8_d24_unorm_pack32,
    d24_unorm_s8_uint,
    d32_sfloat,
    d32_sfloat_s8_uint,
    bc7_unorm,
}

VkExtent2D :: struct {
    width: u32
    height: u32
}

VkResult :: enum {
    success,
    error_out_of_host_memory,
    error_out_of_device_memory,
    error_device_lost,
    error_surface_lost,
    error_native_window_in_use_khr,
    error_extension_not_present,
    error_feature_not_present,
    error_incompatible_driver,
}

VulkanMesh :: struct {
    vertex_buffer: VkBuffer
    vertex_memory: VkDeviceMemory
    index_buffer: VkBuffer
    index_memory: VkDeviceMemory
    index_count: u32
    
    vertex_count: u32
}

VulkanTexture :: struct {
    image: VkImage
    memory: VkDeviceMemory
    image_view: VkImageView
    sampler: VkSampler
    
    width: u32
    height: u32
}

InitVulkanBackend :: proc() -> VulkanBackend {
    return VulkanBackend{
        initialized = false,
        max_frames_in_flight = 2,
        clear_color = {0.1, 0.12, 0.18, 1.0},
        clear_depth = 1.0,
        vsync = true,
    }
}

CreateVulkanInstance :: proc(backend: ^VulkanBackend, app_name: string) -> VkResult {
    app_info := VkApplicationInfo{
        api_version = VK_MAKE_VERSION(1, 3, 0),
        application_name = app_name,
        engine_name = "Game Desktop",
    }
    
    extensions := GetRequiredExtensions()
    
    layers := GetValidationLayers()
    
    create_info := VkInstanceCreateInfo{
        application_info = &app_info,
        enabled_extension_count = u32(len(extensions)),
        enabled_extensions = extensions,
        enabled_layer_count = u32(len(layers)),
        enabled_layers = layers,
    }
    
    result := vkCreateInstance(&create_info, nil, &backend.instance)
    if result != .success {
        fmt.println("Failed to create Vulkan instance")
        return result
    }
    
    return .success
}

GetRequiredExtensions :: proc() -> []string {
    return []string{
        "VK_KHR_surface",
        "VK_KHR_win32_surface",
    }
}

GetValidationLayers :: proc() -> []string {
    return []string{
        "VK_LAYER_KHRONOS_validation",
    }
}

PickPhysicalDevice :: proc(backend: ^VulkanBackend) -> VkResult {
    device_count: u32 = 0
    vkEnumeratePhysicalDevices(backend.instance, &device_count, nil)
    
    if device_count == 0 {
        fmt.println("No Vulkan-capable GPUs found")
        return .error_out_of_device_memory
    }
    
    devices := make([]VkPhysicalDevice, device_count)
    vkEnumeratePhysicalDevices(backend.instance, &device_count, &devices[0])
    
    for _, device in devices {
        properties := VkPhysicalDeviceProperties{}
        vkGetPhysicalDeviceProperties(device, &properties)
        fmt.println("Found GPU:", properties.device_name)
        
        if properties.device_type == VULKAN_DISCRETE_GPU {
            backend.physical_device = device
            break
        }
    }
    
    if backend.physical_device.handle == 0 {
        backend.physical_device = devices[0]
    }
    
    mem.free(devices)
    
    return .success
}

CreateLogicalDevice :: proc(backend: ^VulkanBackend) -> VkResult {
    queue_families := FindQueueFamilies(backend.physical_device)
    
    queue_priorities := [1]f32{1.0}
    queue_infos := []VkDeviceQueueCreateInfo{
        {
            queue_family_index = queue_families.graphics_family,
            queue_count = 1,
            queue_priorities = &queue_priorities[0],
        },
    }
    
    features := VkPhysicalDeviceFeatures{
        fill_mode_non_solid = true,
        sampler_anisotropy = true,
    }
    
    device_create_info := VkDeviceCreateInfo{
        queue_create_info_count = u32(len(queue_infos)),
        queue_create_infos = queue_infos,
        enabled_feature_count = 1,
        enabled_features = &features,
    }
    
    result := vkCreateDevice(backend.physical_device, &device_create_info, nil, &backend.device)
    if result != .success {
        fmt.println("Failed to create logical device")
        return result
    }
    
    vkGetDeviceQueue(backend.device, queue_families.graphics_family, 0, &backend.graphics_queue)
    vkGetDeviceQueue(backend.device, queue_families.present_family, 0, &backend.present_queue)
    
    return .success
}

FindQueueFamilies :: proc(device: VkPhysicalDevice) -> QueueFamilies {
    families := QueueFamilies{}
    
    count: u32 = 0
    vkGetPhysicalDeviceQueueFamilies(device, &count, nil)
    
    queues := make([]VkQueueFamilyProperties, count)
    vkGetPhysicalDeviceQueueFamilies(device, &count, &queues[0])
    
    for i := u32(0); i < count; i++ {
        if queues[i].queue_flags & VK_QUEUE_GRAPHICS_BIT != 0 {
            families.graphics_family = i
        }
    }
    
    families.present_family = families.graphics_family
    
    return families
}

QueueFamilies :: struct {
    graphics_family: u32
    present_family: u32
}

CreateSwapchain :: proc(backend: ^VulkanBackend, window: rawptr) -> VkResult {
    swapchain_support := QuerySwapchainSupport(backend.physical_device)
    
    surface_formats := swapchain_support.formats
    present_modes := swapchain_support.present_modes
    
    surface_format := surface_formats[0]
    for _, format in surface_formats {
        if format.format == VK_FORMAT_B8G8R8A8_UNORM && format.color_space == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR {
            surface_format = format
            break
        }
    }
    
    present_mode := VK_PRESENT_MODE_FIFO_KHR
    for _, mode in present_modes {
        if mode == VK_PRESENT_MODE_MAILBOX_KHR {
            present_mode = mode
            break
        }
    }
    
    if !backend.vsync {
        for _, mode in present_modes {
            if mode == VK_PRESENT_MODE_IMMEDIATE_KHR {
                present_mode = mode
                break
            }
        }
    }
    
    extent := VkExtent2D{
        width = u32(1280),
        height = u32(720),
    }
    
    if swapchain_support.capabilities.current_transform & VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR != 0 {
        extent = swapchain_support.capabilities.current_extent
    }
    
    image_count := swapchain_support.capabilities.min_image_count + 1
    if swapchain_support.capabilities.max_image_count > 0 {
        if image_count > swapchain_support.capabilities.max_image_count {
            image_count = swapchain_support.capabilities.max_image_count
        }
    }
    
    create_info := VkSwapchainCreateInfoKHR{
        surface = backend.surface,
        min_image_count = image_count,
        image_format = surface_format.format,
        image_color_space = surface_format.color_space,
        image_extent = extent,
        image_array_layers = 1,
        image_usage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        image_sharing_mode = VK_SHARING_MODE_EXCLUSIVE,
        pre_transform = swapchain_support.capabilities.current_transform,
        composite_alpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
        present_mode = present_mode,
        clipped = true,
    }
    
    result := vkCreateSwapchain(backend.device, &create_info, nil, &backend.swapchain)
    if result != .success {
        fmt.println("Failed to create swapchain")
        return result
    }
    
    backend.swapchain_image_format = surface_format.format
    backend.swapchain_extent = extent
    
    vkGetSwapchainImages(backend.device, backend.swapchain, &image_count, nil)
    backend.swapchain_images = make([]VkImage, image_count)
    vkGetSwapchainImages(backend.device, backend.swapchain, &image_count, &backend.swapchain_images[0])
    
    backend.swapchain_image_views = make([]VkImageView, image_count)
    for i := u32(0); i < image_count; i++ {
        CreateImageView(backend, backend.swapchain_images[i], backend.swapchain_image_format, &backend.swapchain_image_views[i])
    }
    
    return .success
}

QuerySwapchainSupport :: proc(device: VkPhysicalDevice) -> SwapchainSupport {
    support := SwapchainSupport{}
    
    vkGetPhysicalDeviceSurfaceCapabilities(device, 0, &support.capabilities)
    
    format_count: u32 = 0
    vkGetPhysicalDeviceSurfaceFormats(device, 0, &format_count, nil)
    
    if format_count > 0 {
        support.formats = make([]VkSurfaceFormat, format_count)
        vkGetPhysicalDeviceSurfaceFormats(device, 0, &format_count, &support.formats[0])
    }
    
    present_mode_count: u32 = 0
    vkGetPhysicalDeviceSurfacePresentModes(device, 0, &present_mode_count, nil)
    
    if present_mode_count > 0 {
        support.present_modes = make([]u32, present_mode_count)
        vkGetPhysicalDeviceSurfacePresentModes(device, 0, &present_mode_count, &support.present_modes[0])
    }
    
    return support
}

SwapchainSupport :: struct {
    capabilities: VkSurfaceCapabilities
    formats: []VkSurfaceFormat
    present_modes: []u32
}

VkSurfaceCapabilities :: struct {
    min_image_count: u32
    max_image_count: u32
    current_extent: VkExtent2D
    current_transform: u32
    supported_transforms: u32
    supported_composite_alpha: u32
    supported_usage_flags: u32
}

VkSurfaceFormat :: struct {
    format: VkFormat
    color_space: u32
}

CreateImageView :: proc(backend: ^VulkanBackend, image: VkImage, format: VkFormat, view: ^VkImageView) {
    create_info := VkImageViewCreateInfo{
        image = image,
        view_type = VK_IMAGE_VIEW_TYPE_2D,
        format = format,
        subresource_range = VkImageSubresourceRange{
            aspect_mask = VK_IMAGE_ASPECT_COLOR_BIT,
            base_mip_level = 0,
            level_count = 1,
            base_array_layer = 0,
            layer_count = 1,
        },
    }
    
    vkCreateImageView(backend.device, &create_info, nil, view)
}

CreateRenderPass :: proc(backend: ^VulkanBackend) -> VkResult {
    color_attachment := VkAttachmentDescription{
        format = backend.swapchain_image_format,
        samples = VK_SAMPLE_COUNT_1_BIT,
        load_op = VK_ATTACHMENT_LOAD_OP_CLEAR,
        store_op = VK_ATTACHMENT_STORE_OP_STORE,
        stencil_load_op = VK_ATTACHMENT_LOAD_OP_DONT_CARE,
        stencil_store_op = VK_ATTACHMENT_STORE_OP_DONT_CARE,
        initial_layout = VK_IMAGE_LAYOUT_UNDEFINED,
        final_layout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
    }
    
    color_attachment_ref := VkAttachmentReference{
        attachment = 0,
        layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
    }
    
    subpass := VkSubpassDescription{
        pipeline_bind_point = VK_PIPELINE_BIND_POINT_GRAPHICS,
        color_attachment_count = 1,
        color_attachments = &color_attachment_ref,
    }
    
    dependency := VkSubpassDependency{
        src_subpass = VK_SUBPASS_EXTERNAL,
        dst_subpass = 0,
        src_stage_mask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
        dst_stage_mask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
        src_access_mask = 0,
        dst_access_mask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
    }
    
    render_pass_info := VkRenderPassCreateInfo{
        attachment_count = 1,
        attachments = &color_attachment,
        subpass_count = 1,
        subpasses = &subpass,
        dependency_count = 1,
        dependencies = &dependency,
    }
    
    result := vkCreateRenderPass(backend.device, &render_pass_info, nil, &backend.render_pass)
    if result != .success {
        fmt.println("Failed to create render pass")
        return result
    }
    
    return .success
}

CreateGraphicsPipeline :: proc(backend: ^VulkanBackend) -> VkResult {
    vertex_shader := CreateShaderModule(backend, DefaultVertexShader())
    fragment_shader := CreateShaderModule(backend, DefaultFragmentShader())
    
    shader_stages := []VkPipelineShaderStageCreateInfo{
        {
            stage = VK_SHADER_STAGE_VERTEX_BIT,
            module = vertex_shader,
            name = "main",
        },
        {
            stage = VK_SHADER_STAGE_FRAGMENT_BIT,
            module = fragment_shader,
            name = "main",
        },
    }
    
    vertex_input_state := VkPipelineVertexInputStateCreateInfo{}
    
    input_assembly_state := VkPipelineInputAssemblyStateCreateInfo{
        topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST,
        primitive_restart_enable = false,
    }
    
    viewport := VkViewport{
        width = f32(backend.swapchain_extent.width),
        height = f32(backend.swapchain_extent.height),
        min_depth = 0.0,
        max_depth = 1.0,
    }
    
    scissor := VkRect2D{
        offset = {0, 0},
        extent = backend.swapchain_extent,
    }
    
    viewport_state := VkPipelineViewportStateCreateInfo{
        viewport_count = 1,
        viewports = &viewport,
        scissor_count = 1,
        scissors = &scissor,
    }
    
    rasterization_state := VkPipelineRasterizationStateCreateInfo{
        depth_clamp_enable = false,
        rasterizer_discard_enable = false,
        polygon_mode = VK_POLYGON_MODE_FILL,
        line_width = 1.0,
        cull_mode = VK_CULL_MODE_BACK_BIT,
        front_face = VK_FRONT_FACE_COUNTER_CLOCKWISE,
    }
    
    multisample_state := VkPipelineMultisampleStateCreateInfo{
        sample_shading_enable = false,
        rasterization_samples = VK_SAMPLE_COUNT_1_BIT,
    }
    
    color_blend_attachment := VkPipelineColorBlendAttachmentState{
        color_write_mask = VK_COLOR_COMPONENT_R_BIT | VK_COLOR_COMPONENT_G_BIT | VK_COLOR_COMPONENT_B_BIT | VK_COLOR_COMPONENT_A_BIT,
        blend_enable = false,
    }
    
    color_blend_state := VkPipelineColorBlendStateCreateInfo{
        logic_op_enable = false,
        attachment_count = 1,
        attachments = &color_blend_attachment,
    }
    
    pipeline_info := VkGraphicsPipelineCreateInfo{
        stage_count = u32(len(shader_stages)),
        stages = shader_stages,
        vertex_input_state = &vertex_input_state,
        input_assembly_state = &input_assembly_state,
        viewport_state = &viewport_state,
        rasterization_state = &rasterization_state,
        multisample_state = &multisample_state,
        color_blend_state = &color_blend_state,
        layout = backend.pipeline_layout,
        render_pass = backend.render_pass,
        subpass = 0,
    }
    
    result := vkCreateGraphicsPipelines(backend.device, 0, 1, &pipeline_info, nil, &backend.pipeline)
    if result != .success {
        fmt.println("Failed to create graphics pipeline")
        return result
    }
    
    return .success
}

CreateShaderModule :: proc(backend: ^VulkanBackend, code: string) -> VkShaderModule {
    create_info := VkShaderModuleCreateInfo{
        code_size = u64(len(code)),
        code = cast(^u32)(&code[0]),
    }
    
    module: VkShaderModule
    vkCreateShaderModule(backend.device, &create_info, nil, &module)
    
    return module
}

DefaultVertexShader :: proc() -> string {
    return `#version 450
#extension GL_ARB_separate_shader_types : enable

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 uv;

layout(location = 0) out vec3 fragPos;
layout(location = 1) out vec3 normal;
layout(location = 2) out vec2 texCoord;

layout(set = 0, binding = 0) uniform UniformBufferObject {
    mat4 model;
    mat4 view;
    mat4 projection;
} ubo;

void main() {
    fragPos = vec3(ubo.model * vec4(position, 1.0));
    normal = mat3(transpose(inverse(ubo.model))) * normal;
    texCoord = uv;
    gl_Position = ubo.projection * ubo.view * ubo.model * vec4(position, 1.0);
}`
}

DefaultFragmentShader :: proc() -> string {
    return `#version 450
#extension GL_ARB_separate_shader_types : enable

layout(location = 0) in vec3 fragPos;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 texCoord;

layout(location = 0) out vec4 outColor;

struct Light {
    vec3 position;
    vec3 color;
    float intensity;
};

layout(set = 0, binding = 1) uniform LightsUniform {
    vec3 cameraPos;
    int lightCount;
    Light lights[4];
} lights;

void main() {
    vec3 color = vec3(0.7, 0.8, 0.9);
    vec3 N = normalize(normal);
    vec3 viewDir = normalize(lights.cameraPos - fragPos);
    
    vec3 result = color * 0.15;
    
    for(int i = 0; i < 4 && i < lights.lightCount; i++) {
        vec3 lightDir = normalize(lights.lights[i].position - fragPos);
        float diff = max(dot(N, lightDir), 0.0);
        result += diff * lights.lights[i].color * color * lights.lights[i].intensity;
    }
    
    outColor = vec4(result, 1.0);
}`
}

CreateFramebuffers :: proc(backend: ^VulkanBackend) -> VkResult {
    framebuffer_count := u32(len(backend.swapchain_image_views))
    backend.swapchain_framebuffers = make([]VkFramebuffer, framebuffer_count)
    
    for i := u32(0); i < framebuffer_count; i++ {
        attachments := []VkImageView{ backend.swapchain_image_views[i] }
        
        create_info := VkFramebufferCreateInfo{
            render_pass = backend.render_pass,
            attachment_count = 1,
            attachments = attachments,
            width = backend.swapchain_extent.width,
            height = backend.swapchain_extent.height,
            layers = 1,
        }
        
        result := vkCreateFramebuffer(backend.device, &create_info, nil, &backend.swapchain_framebuffers[i])
        if result != .success {
            fmt.println("Failed to create framebuffer")
            return result
        }
    }
    
    return .success
}

CreateCommandPool :: proc(backend: ^VulkanBackend) -> VkResult {
    queue_families := FindQueueFamilies(backend.physical_device)
    
    pool_info := VkCommandPoolCreateInfo{
        queue_family_index = queue_families.graphics_family,
        flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
    }
    
    result := vkCreateCommandPool(backend.device, &pool_info, nil, &backend.command_pool)
    if result != .success {
        fmt.println("Failed to create command pool")
        return result
    }
    
    backend.command_buffers = make([]VkCommandBuffer, backend.max_frames_in_flight)
    
    buffer_info := VkCommandBufferAllocateInfo{
        command_pool = backend.command_pool,
        level = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        command_buffer_count = u32(backend.max_frames_in_flight),
    }
    
    vkAllocateCommandBuffers(backend.device, &buffer_info, &backend.command_buffers[0])
    
    return .success
}

CreateSyncObjects :: proc(backend: ^VulkanBackend) -> VkResult {
    semaphore_info := VkSemaphoreCreateInfo{}
    fence_info := VkFenceCreateInfo{
        flags = VK_FENCE_CREATE_SIGNALED_BIT,
    }
    
    backend.image_available_semaphores = make([]VkSemaphore, backend.max_frames_in_flight)
    backend.render_finished_semaphores = make([]VkSemaphore, backend.max_frames_in_flight)
    backend.in_flight_fences = make([]VkFence, backend.max_frames_in_flight)
    
    for i := 0; i < backend.max_frames_in_flight; i++ {
        vkCreateSemaphore(backend.device, &semaphore_info, nil, &backend.image_available_semaphores[i])
        vkCreateSemaphore(backend.device, &semaphore_info, nil, &backend.render_finished_semaphores[i])
        vkCreateFence(backend.device, &fence_info, nil, &backend.in_flight_fences[i])
    }
    
    return .success
}

BeginFrame :: proc(backend: ^VulkanBackend) -> VkResult {
    vkWaitForFences(backend.device, 1, &backend.in_flight_fences[backend.current_frame], true, U64_MAX)
    
    image_index: u32 = 0
    result := vkAcquireNextImage(backend.device, backend.swapchain, U64_MAX, backend.image_available_semaphores[backend.current_frame], 0, &image_index)
    
    if result == .error_out_of_date_khr {
        return RecreateSwapchain(backend)
    }
    if result != .success {
        fmt.println("Failed to acquire swap chain image")
        return result
    }
    
    vkResetFences(backend.device, 1, &backend.in_flight_fences[backend.current_frame])
    
    cmd := backend.command_buffers[backend.current_frame]
    vkResetCommandBuffer(cmd, 0)
    
    begin_info := VkCommandBufferBeginInfo{
        flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
    }
    
    vkBeginCommandBuffer(cmd, &begin_info)
    
    return .success
}

EndFrame :: proc(backend: ^VulkanBackend, image_index: u32) {
    cmd := backend.command_buffers[backend.current_frame]
    vkEndCommandBuffer(cmd)
    
    wait_semaphores := []VkSemaphore{ backend.image_available_semaphores[backend.current_frame] }
    wait_stages := []VkPipelineStageFlags{ VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT }
    signal_semaphores := []VkSemaphore{ backend.render_finished_semaphores[backend.current_frame] }
    
    submit_info := VkSubmitInfo{
        wait_semaphore_count = 1,
        wait_semaphores = wait_semaphores,
        wait_dst_stage_mask = wait_stages,
        command_buffer_count = 1,
        command_buffers = &cmd,
        signal_semaphore_count = 1,
        signal_semaphores = signal_semaphores,
    }
    
    vkQueueSubmit(backend.graphics_queue, 1, &submit_info, backend.in_flight_fences[backend.current_frame])
    
    present_info := VkPresentInfo{
        wait_semaphore_count = 1,
        wait_semaphores = signal_semaphores,
        swapchain_count = 1,
        swapchains = &backend.swapchain,
        image_indices = &image_index,
    }
    
    result := vkQueuePresent(backend.present_queue, &present_info)
    
    if result == .error_out_of_date_khr || result == .suboptimal_khr {
        RecreateSwapchain(backend)
    }
    
    backend.current_frame = (backend.current_frame + 1) % backend.max_frames_in_flight
}

RecreateSwapchain :: proc(backend: ^VulkanBackend) -> VkResult {
    return .success
}

ShutdownVulkanBackend :: proc(backend: ^VulkanBackend) {
    if !backend.initialized {
        return
    }
    
    vkDeviceWaitIdle(backend.device)
    
    for i := 0; i < backend.max_frames_in_flight; i++ {
        if backend.in_flight_fences[i].handle != 0 {
            vkDestroyFence(backend.device, backend.in_flight_fences[i], nil)
        }
        if backend.render_finished_semaphores[i].handle != 0 {
            vkDestroySemaphore(backend.device, backend.render_finished_semaphores[i], nil)
        }
        if backend.image_available_semaphores[i].handle != 0 {
            vkDestroySemaphore(backend.device, backend.image_available_semaphores[i], nil)
        }
    }
    
    if backend.command_pool.handle != 0 {
        vkDestroyCommandPool(backend.device, backend.command_pool, nil)
    }
    
    for _, fb in backend.swapchain_framebuffers {
        if fb.handle != 0 {
            vkDestroyFramebuffer(backend.device, fb, nil)
        }
    }
    
    if backend.pipeline.handle != 0 {
        vkDestroyPipeline(backend.device, backend.pipeline, nil)
    }
    
    if backend.pipeline_layout.handle != 0 {
        vkDestroyPipelineLayout(backend.device, backend.pipeline_layout, nil)
    }
    
    if backend.render_pass.handle != 0 {
        vkDestroyRenderPass(backend.device, backend.render_pass, nil)
    }
    
    for _, view in backend.swapchain_image_views {
        if view.handle != 0 {
            vkDestroyImageView(backend.device, view, nil)
        }
    }
    
    if backend.swapchain.handle != 0 {
        vkDestroySwapchain(backend.device, backend.swapchain, nil)
    }
    
    if backend.device.handle != 0 {
        vkDestroyDevice(backend.device, nil)
    }
    
    if backend.surface.handle != 0 {
        vkDestroySurface(backend.instance, backend.surface, nil)
    }
    
    if backend.instance.handle != 0 {
        vkDestroyInstance(backend.instance, nil)
    }
    
    backend.initialized = false
}

UpdateCamera :: proc(backend: ^VulkanBackend, dt: f32) {
    camera.UpdateCameraInput(&backend.camera, &backend.camera_input, dt)
}

GetCamera :: proc(backend: ^VulkanBackend) -> ^camera.Camera {
    return &backend.camera
}

GetCameraInput :: proc(backend: ^VulkanBackend) -> ^camera.CameraInputState {
    return &backend.camera_input
}

CalcWindowPlacement :: proc(backend: ^VulkanBackend, distance: f32) -> camera.WindowPlacement {
    return camera.CalcWindowPlacement(backend.camera, distance)
}

CreateVertexBuffer :: proc(backend: ^VulkanBackend, vertices: rawptr, size: u64) -> VulkanMesh {
    mesh := VulkanMesh{}
    
    BufferCreateInfo(backend, vertices, size, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT, &mesh.vertex_buffer, &mesh.vertex_memory)
    mesh.vertex_count = u32(size) / size_of(Vertex)
    
    return mesh
}

CreateIndexBuffer :: proc(backend: ^VulkanBackend, indices: rawptr, count: u32) -> VulkanMesh {
    mesh := VulkanMesh{}
    size := u64(count) * 4
    
    BufferCreateInfo(backend, indices, size, VK_BUFFER_USAGE_INDEX_BUFFER_BIT, &mesh.index_buffer, &mesh.index_memory)
    mesh.index_count = count
    
    return mesh
}

BufferCreateInfo :: proc(backend: ^VulkanBackend, data: rawptr, size: u64, usage: u32, buffer: ^VkBuffer, memory: ^VkDeviceMemory) {
    staging : VkBuffer
    staging_mem : VkDeviceMemory
    
    buffer_info := VkBufferCreateInfo{
        size = size,
        usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT,
        sharing_mode = VK_SHARING_MODE_EXCLUSIVE,
    }
    
    vkCreateBuffer(backend.device, &buffer_info, nil, &staging)
    
    mem_reqs : VkMemoryRequirements
    vkGetBufferMemoryRequirements(backend.device, staging, &mem_reqs)
    
    mem AllocateInfo(backend, mem_reqs.size, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT, &staging_mem)
    
    vkBindBufferMemory(backend.device, staging, staging_mem, 0)
    
    CopyMemory(staging_mem, data, size)
    
    buffer_info.usage = usage
    vkCreateBuffer(backend.device, &buffer_info, nil, buffer)
    
    vkGetBufferMemoryRequirements(backend.device, buffer^, &mem_reqs)
    
    AllocateInfo(backend, mem_reqs.size, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT, memory)
    vkBindBufferMemory(backend.device, buffer^, memory^, 0)
    
    CopyBuffer(buffer^, staging, size)
    
    vkDestroyBuffer(backend.device, staging, nil)
    vkFreeMemory(backend.device, staging_mem, nil)
}

AllocateInfo :: proc(backend: ^VulkanBackend, size: u64, properties: u32, memory: ^VkDeviceMemory) {
    mem_reqs := VkMemoryRequirements{
        size = size,
    }
    
    allocate_info := VkMemoryAllocateInfo{
        allocation_size = size,
        memory_type_index = FindMemoryType(backend, mem_reqs.memory_type_bits, properties),
    }
    
    vkAllocateMemory(backend.device, &allocate_info, nil, memory)
}

FindMemoryType :: proc(backend: ^VulkanBackend, type_filter: u32, properties: u32) -> u32 {
    prop_flags : VkPhysicalDeviceMemoryProperties
    vkGetPhysicalDeviceMemoryProperties(backend.physical_device, &prop_flags)
    
    for i := u32(0); i < prop_flags.memory_type_count; i++ {
        if (type_filter & (1 << i)) != 0 {
            if prop_flags.memory_types[i].property_flags & properties == properties {
                return i
            }
        }
    }
    
    return 0
}

CopyMemory :: proc(memory: VkDeviceMemory, data: rawptr, size: u64) {
}

CopyBuffer :: proc(buffer: VkBuffer, staging: VkBuffer, size: u64) {
}

Vertex :: struct {
    position: camera.Vec3
    normal: camera.Vec3
    uv: camera.Vec2
}

VkApplicationInfo :: struct {
    api_version: u32
    application_name: string
    engine_name: string
}

VkInstanceCreateInfo :: struct {
    application_info: ^VkApplicationInfo
    enabled_extension_count: u32
    enabled_extensions: []string
    enabled_layer_count: u32
    enabled_layers: []string
}

VkDeviceCreateInfo :: struct {
    queue_create_info_count: u32
    queue_create_infos: []VkDeviceQueueCreateInfo
    enabled_feature_count: u32
    enabled_features: ^VkPhysicalDeviceFeatures
}

VkDeviceQueueCreateInfo :: struct {
    queue_family_index: u32
    queue_count: u32
    queue_priorities: ^f32
}

VkPhysicalDeviceFeatures :: struct {
    fill_mode_non_solid: bool
    sampler_anisotropy: bool
}

VkPhysicalDeviceProperties :: struct {
    device_name: string
    device_type: u32
}

VkQueueFamilyProperties :: struct {
    queue_flags: u32
    queue_count: u32
}

VkSwapchainCreateInfoKHR :: struct {
    surface: VkSurfaceKHR
    min_image_count: u32
    image_format: VkFormat
    image_color_space: u32
    image_extent: VkExtent2D
    image_array_layers: u32
    image_usage: u32
    image_sharing_mode: u32
    pre_transform: u32
    composite_alpha: u32
    present_mode: u32
    clipped: bool
}

VkImageViewCreateInfo :: struct {
    image: VkImage
    view_type: u32
    format: VkFormat
    subresource_range: VkImageSubresourceRange
}

VkImageSubresourceRange :: struct {
    aspect_mask: u32
    base_mip_level: u32
    level_count: u32
    base_array_layer: u32
    layer_count: u32
}

VkAttachmentDescription :: struct {
    format: VkFormat
    samples: u32
    load_op: u32
    store_op: u32
    stencil_load_op: u32
    stencil_store_op: u32
    initial_layout: u32
    final_layout: u32
}

VkAttachmentReference :: struct {
    attachment: u32
    layout: u32
}

VkSubpassDescription :: struct {
    pipeline_bind_point: u32
    color_attachment_count: u32
    color_attachments: ^VkAttachmentReference
}

VkSubpassDependency :: struct {
    src_subpass: u32
    dst_subpass: u32
    src_stage_mask: u32
    dst_stage_mask: u32
    src_access_mask: u32
    dst_access_mask: u32
}

VkRenderPassCreateInfo :: struct {
    attachment_count: u32
    attachments: ^VkAttachmentDescription
    subpass_count: u32
    subpasses: ^VkSubpassDescription
    dependency_count: u32
    dependencies: ^VkSubpassDependency
}

VkShaderModuleCreateInfo :: struct {
    code_size: u64
    code: ^u32
}

VkPipelineShaderStageCreateInfo :: struct {
    stage: u32
    module: VkShaderModule
    name: string
}

VkPipelineVertexInputStateCreateInfo :: struct {}

VkPipelineInputAssemblyStateCreateInfo :: struct {
    topology: u32
    primitive_restart_enable: bool
}

VkPipelineViewportStateCreateInfo :: struct {
    viewport_count: u32
    viewports: ^VkViewport
    scissor_count: u32
    scissors: ^VkRect2D
}

VkViewport :: struct {
    width: f32
    height: f32
    min_depth: f32
    max_depth: f32
}

VkRect2D :: struct {
    offset: VkOffset2D
    extent: VkExtent2D
}

VkOffset2D :: struct {
    x: i32
    y: i32
}

VkPipelineRasterizationStateCreateInfo :: struct {
    depth_clamp_enable: bool
    rasterizer_discard_enable: bool
    polygon_mode: u32
    line_width: f32
    cull_mode: u32
    front_face: u32
}

VkPipelineMultisampleStateCreateInfo :: struct {
    sample_shading_enable: bool
    rasterization_samples: u32
}

VkPipelineColorBlendAttachmentState :: struct {
    color_write_mask: u32
    blend_enable: bool
}

VkPipelineColorBlendStateCreateInfo :: struct {
    logic_op_enable: bool
    attachment_count: u32
    attachments: ^VkPipelineColorBlendAttachmentState
}

VkGraphicsPipelineCreateInfo :: struct {
    stage_count: u32
    stages: []VkPipelineShaderStageCreateInfo
    vertex_input_state: ^VkPipelineVertexInputStateCreateInfo
    input_assembly_state: ^VkPipelineInputAssemblyStateCreateInfo
    viewport_state: ^VkPipelineViewportStateCreateInfo
    rasterization_state: ^VkPipelineRasterizationStateCreateInfo
    multisample_state: ^VkPipelineMultisampleStateCreateInfo
    color_blend_state: ^VkPipelineColorBlendStateCreateInfo
    layout: VkPipelineLayout
    render_pass: VkRenderPass
    subpass: u32
}

VkFramebufferCreateInfo :: struct {
    render_pass: VkRenderPass
    attachment_count: u32
    attachments: []VkImageView
    width: u32
    height: u32
    layers: u32
}

VkCommandPoolCreateInfo :: struct {
    queue_family_index: u32
    flags: u32
}

VkCommandBufferAllocateInfo :: struct {
    command_pool: VkCommandPool
    level: u32
    command_buffer_count: u32
}

VkCommandBufferBeginInfo :: struct {
    flags: u32
}

VkSubmitInfo :: struct {
    wait_semaphore_count: u32
    wait_semaphores: []VkSemaphore
    wait_dst_stage_mask: []VkPipelineStageFlags
    command_buffer_count: u32
    command_buffers: ^VkCommandBuffer
    signal_semaphore_count: u32
    signal_semaphores: []VkSemaphore
}

VkPresentInfo :: struct {
    wait_semaphore_count: u32
    wait_semaphores: []VkSemaphore
    swapchain_count: u32
    swapchains: ^VkSwapchainKHR
    image_indices: ^u32
}

VkSemaphoreCreateInfo :: struct {
    flags: u32
}

VkFenceCreateInfo :: struct {
    flags: u32
}

VkBufferCreateInfo :: struct {
    size: u64
    usage: u32
    sharing_mode: u32
}

VkMemoryRequirements :: struct {
    size: u64
    alignment: u64
    memory_type_bits: u32
}

VkMemoryAllocateInfo :: struct {
    allocation_size: u64
    memory_type_index: u32
}

VkPhysicalDeviceMemoryProperties :: struct {
    memory_type_count: u32
    memory_types: []VkMemoryProperty
}

VkMemoryProperty :: struct {
    property_flags: u32
    heap_index: u32
}

VK_MAKE_VERSION :: proc(major, minor, patch: u32) -> u32 {
    return (major << 22) | (minor << 12) | patch
}

VK_NULL_HANDLE :: 0

U64_MAX :: u64(0xFFFFFFFFFFFFFFFF)

vkCreateInstance :: proc(info: ^VkInstanceCreateInfo, allocator: rawptr, instance: ^VkInstance) -> VkResult {}
vkDestroyInstance :: proc(instance: VkInstance, allocator: rawptr) {}
vkEnumeratePhysicalDevices :: proc(instance: VkInstance, count: ^u32, devices: ^VkPhysicalDevice) -> VkResult {}
vkGetPhysicalDeviceProperties :: proc(device: VkPhysicalDevice, props: ^VkPhysicalDeviceProperties) {}
vkGetPhysicalDeviceQueueFamilies :: proc(device: VkPhysicalDevice, count: ^u32, props: ^VkQueueFamilyProperties) {}
vkCreateDevice :: proc(device: VkPhysicalDevice, info: ^VkDeviceCreateInfo, allocator: rawptr, out: ^VkDevice) -> VkResult {}
vkDestroyDevice :: proc(device: VkDevice, allocator: rawptr) {}
vkGetDeviceQueue :: proc(device: VkDevice, family: u32, queue: u32, out: ^VkQueue) {}
vkCreateSwapchain :: proc(device: VkDevice, info: ^VkSwapchainCreateInfoKHR, allocator: rawptr, out: ^VkSwapchainKHR) -> VkResult {}
vkDestroySwapchain :: proc(device: VkDevice, swapchain: VkSwapchainKHR, allocator: rawptr) {}
vkGetSwapchainImages :: proc(device: VkDevice, swapchain: VkSwapchainKHR, count: ^u32, images: ^VkImage) -> VkResult {}
vkCreateImageView :: proc(device: VkDevice, info: ^VkImageViewCreateInfo, allocator: rawptr, out: ^VkImageView) -> VkResult {}
vkDestroyImageView :: proc(device: VkDevice, view: VkImageView, allocator: rawptr) {}
vkCreateRenderPass :: proc(device: VkDevice, info: ^VkRenderPassCreateInfo, allocator: rawptr, out: ^VkRenderPass) -> VkResult {}
vkDestroyRenderPass :: proc(device: VkDevice, render_pass: VkRenderPass, allocator: rawptr) {}
vkCreateGraphicsPipelines :: proc(device: VkDevice, pipeline_cache: VkPipelineCache, count: i32, info: ^VkGraphicsPipelineCreateInfo, allocator: rawptr, out: ^VkPipeline) -> VkResult {}
vkDestroyPipeline :: proc(device: VkDevice, pipeline: VkPipeline, allocator: rawptr) {}
vkDestroyPipelineLayout :: proc(device: VkDevice, layout: VkPipelineLayout, allocator: rawptr) {}
vkCreateFramebuffer :: proc(device: VkDevice, info: ^VkFramebufferCreateInfo, allocator: rawptr, out: ^VkFramebuffer) -> VkResult {}
vkDestroyFramebuffer :: proc(device: VkDevice, fb: VkFramebuffer, allocator: rawptr) {}
vkCreateCommandPool :: proc(device: VkDevice, info: ^VkCommandPoolCreateInfo, allocator: rawptr, out: ^VkCommandPool) -> VkResult {}
vkDestroyCommandPool :: proc(device: VkDevice, pool: VkCommandPool, allocator: rawptr) {}
vkAllocateCommandBuffers :: proc(device: VkDevice, info: ^VkCommandBufferAllocateInfo, out: ^VkCommandBuffer) -> VkResult {}
vkBeginCommandBuffer :: proc(buffer: VkCommandBuffer, info: ^VkCommandBufferBeginInfo) -> VkResult {}
vkEndCommandBuffer :: proc(buffer: VkCommandBuffer) -> VkResult {}
vkResetCommandBuffer :: proc(buffer: VkCommandBuffer, flags: u32) -> VkResult {}
vkCreateSemaphore :: proc(device: VkDevice, info: ^VkSemaphoreCreateInfo, allocator: rawptr, out: ^VkSemaphore) -> VkResult {}
vkDestroySemaphore :: proc(device: VkDevice, semaphore: VkSemaphore, allocator: rawptr) {}
vkCreateFence :: proc(device: VkDevice, info: ^VkFenceCreateInfo, allocator: rawptr, out: ^VkFence) -> VkResult {}
vkDestroyFence :: proc(device: VkDevice, fence: VkFence, allocator: rawptr) {}
vkWaitForFences :: proc(device: VkDevice, count: i32, fences: ^VkFence, wait_all: bool, timeout: u64) -> VkResult {}
vkResetFences :: proc(device: VkDevice, count: i32, fences: ^VkFence) -> VkResult {}
vkAcquireNextImage :: proc(device: VkDevice, swapchain: VkSwapchainKHR, timeout: u64, semaphore: VkSemaphore, fence: VkFence, index: ^u32) -> VkResult {}
vkQueueSubmit :: proc(queue: VkQueue, count: u32, submits: ^VkSubmitInfo, fence: VkFence) -> VkResult {}
vkQueuePresent :: proc(queue: VkQueue, info: ^VkPresentInfo) -> VkResult {}
vkDeviceWaitIdle :: proc(device: VkDevice) -> VkResult {}
vkGetPhysicalDeviceSurfaceCapabilities :: proc(device: VkPhysicalDevice, surface: VkSurfaceKHR, out: ^VkSurfaceCapabilities) -> VkResult {}
vkGetPhysicalDeviceSurfaceFormats :: proc(device: VkPhysicalDevice, surface: VkSurfaceKHR, count: ^u32, formats: ^VkSurfaceFormat) -> VkResult {}
vkGetPhysicalDeviceSurfacePresentModes :: proc(device: VkPhysicalDevice, surface: VkSurfaceKHR, count: ^u32, modes: ^u32) -> VkResult {}
vkDestroySurfaceKHR :: proc(instance: VkInstance, surface: VkSurfaceKHR, allocator: rawptr) {}
vkGetBufferMemoryRequirements :: proc(device: VkDevice, buffer: VkBuffer, out: ^VkMemoryRequirements) {}
vkAllocateMemory :: proc(device: VkDevice, info: ^VkMemoryAllocateInfo, allocator: rawptr, out: ^VkDeviceMemory) -> VkResult {}
vkFreeMemory :: proc(device: VkDevice, memory: VkDeviceMemory, allocator: rawptr) {}
vkBindBufferMemory :: proc(device: VkDevice, buffer: VkBuffer, memory: VkDeviceMemory, offset: u64) -> VkResult {}
vkDestroyBuffer :: proc(device: VkDevice, buffer: VkBuffer, allocator: rawptr) {}

VULKAN_DISCRETE_GPU :: u32(1)

VK_QUEUE_GRAPHICS_BIT :: u32(0x00000001)

VK_FORMAT_B8G8R8A8_UNORM :: VkFormat(44)

VK_COLOR_SPACE_SRGB_NONLINEAR_KHR :: u32(100031)

VK_PRESENT_MODE_FIFO_KHR :: u32(0)
VK_PRESENT_MODE_MAILBOX_KHR :: u32(1)
VK_PRESENT_MODE_IMMEDIATE_KHR :: u32(2)

VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT :: u32(0x00000010)
VK_IMAGE_LAYOUT_UNDEFINED :: u32(0)
VK_IMAGE_LAYOUT_PRESENT_SRC_KHR :: u32(1000001002)
VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL :: u32(1000001004)

VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR :: u32(0x00000001)
VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR :: u32(1)

VK_ATTACHMENT_LOAD_OP_CLEAR :: u32(1)
VK_ATTACHMENT_STORE_OP_STORE :: u32(1)
VK_ATTACHMENT_LOAD_OP_DONT_CARE :: u32(2)
VK_ATTACHMENT_STORE_OP_DONT_CARE :: u32(2)

VK_SUBPASS_EXTERNAL :: u32(0xFFFFFFFF)

VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT :: u32(0x00000400)
VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT :: u32(0x00000010)

VK_SHADER_STAGE_VERTEX_BIT :: u32(0x00000001)
VK_SHADER_STAGE_FRAGMENT_BIT :: u32(0x00000020)

VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST :: u32(3)

VK_CULL_MODE_BACK_BIT :: u32(0x00000002)
VK_FRONT_FACE_COUNTER_CLOCKWISE :: u32(1)

VK_POLYGON_MODE_FILL :: u32(0)

VK_SAMPLE_COUNT_1_BIT :: u32(0x00000001)

VK_COLOR_COMPONENT_R_BIT :: u32(0x00000001)
VK_COLOR_COMPONENT_G_BIT :: u32(0x00000002)
VK_COLOR_COMPONENT_B_BIT :: u32(0x00000004)
VK_COLOR_COMPONENT_A_BIT :: u32(0x00000008)

VK_PIPELINE_BIND_POINT_GRAPHICS :: u32(0)

VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT :: u32(0x00000001)

VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT :: u32(0x00000001)

VK_COMMAND_BUFFER_LEVEL_PRIMARY :: u32(0)

VK_FENCE_CREATE_SIGNALED_BIT :: u32(0x00000001)

VK_BUFFER_USAGE_VERTEX_BUFFER_BIT :: u32(0x00000004)
VK_BUFFER_USAGE_INDEX_BUFFER_BIT :: u32(0x00000002)
VK_BUFFER_USAGE_TRANSFER_SRC_BIT :: u32(0x00000001)

VK_SHARING_MODE_EXCLUSIVE :: u32(0)

VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT :: u32(0x00000001)
VK_MEMORY_PROPERTY_HOST_COHERENT_BIT :: u32(0x00000002)
VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT :: u32(0x00000004)

VK_IMAGE_VIEW_TYPE_2D :: u32(1)
VK_IMAGE_ASPECT_COLOR_BIT :: u32(0x00000001)

VK_PIPELINE_CACHE_HEADER_VERSION_ONE :: u32(0)

error_out_of_date_khr :: VkResult(1000001004)
suboptimal_khr :: VkResult(1000001003)