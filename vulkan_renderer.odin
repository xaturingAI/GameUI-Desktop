package game_desktop

import "core:mem"
import "core:fmt"
import "core:math"


VulkanResult :: enum {
    Success,
    ErrorOutOfHostMemory,
    ErrorOutOfDeviceMemory,
    ErrorInitializationFailed,
    ErrorDeviceLost,
    ErrorExtensionNotPresent,
    ErrorFeatureNotPresent,
    ErrorIncompatibleDriver,
    ErrorUnknown,
}

CullModeFlag :: enum {
    None,
    Front,
    Back,
    FrontAndBack,
}

BlendOp :: enum {
    Add,
    Subtract,
    ReverseSubtract,
    Min,
    Max,
}

BlendFactor :: enum {
    Zero,
    One,
    SrcColor,
    OneMinusSrcColor,
    DstColor,
    OneMinusDstColor,
    SrcAlpha,
    OneMinusSrcAlpha,
    DstAlpha,
    OneMinusDstAlpha,
    ConstantColor,
    OneMinusConstantColor,
    ConstantAlpha,
    OneMinusConstantAlpha,
}

CompareOp :: enum {
    Never,
    Less,
    Equal,
    LessOrEqual,
    Greater,
    NotEqual,
    GreaterOrEqual,
    Always,
}

StencilOp :: enum {
    Keep,
    Zero,
    Replace,
    IncrementAndClamp,
    DecrementAndClamp,
    Invert,
    IncrementAndWrap,
    DecrementAndWrap,
}

PipelineStageFlag :: enum {
    TopOfPipe,
    VertexInput,
    EarlyFragmentTests,
    LateFragmentTests,
    ColorAttachmentOutput,
    Transfer,
    BottomOfPipe,
    Host,
    AllGraphics,
    AllCommands,
}

ImageLayout :: enum {
    Undefined,
    General,
    ColorAttachmentOptimal,
    DepthStencilAttachmentOptimal,
    DepthStencilReadOnlyOptimal,
    ShaderReadOnlyOptimal,
    TransferSrcOptimal,
    TransferDstOptimal,
    Preinitialized,
    PresentSrc,
}

Format :: enum {
    Undefined,
    R4G4UnormPack8,
    R4G4B4A4UnormPack16,
    B4G4R4A4UnormPack16,
    R5G5B5A1UnormPack16,
    B5G5R5A1UnormPack16,
    R8Unorm,
    R8Snorm,
    R8Uscaled,
    R8Sscaled,
    R8Uint,
    R8Sint,
    R8G8Unorm,
    R8G8Snorm,
    R8G8Uscaled,
    R8G8Sscaled,
    R8G8Uint,
    R8G8Sint,
    R8G8B8A8Unorm,
    R8G8B8A8Snorm,
    R8G8B8A8Uscaled,
    R8G8B8A8Sscaled,
    R8G8B8A8Uint,
    R8G8B8Sint,
    B8G8R8A8Unorm,
    A8B8G8R8UnormPack32,
    A2R10G10B10UnormPack32,
    A2B10G10R10UnormPack32,
    R16Unorm,
    R16Snorm,
    R16Uscaled,
    R16Sscaled,
    R16Uint,
    R16Sint,
    R16Sfloat,
    R16G16Unorm,
    R16G16Snorm,
    R16G16Uscaled,
    R16G16Sscaled,
    R16G16Uint,
    R16G16Sint,
    R16G16Sfloat,
    R16G16B16A16Unorm,
    R16G16B16A16Snorm,
    R16G16B16A16Uscaled,
    R16G16B16A16Sscaled,
    R16G16B16A16Uint,
    R16G16B16A16Sint,
    R16G16B16A16Sfloat,
    R32Uint,
    R32Sint,
    R32Sfloat,
    R32G32Uint,
    R32G32Sint,
    R32G32Sfloat,
    R32G32B32Uint,
    R32G32B32Sint,
    R32G32B32Sfloat,
    R32G32B32A32Uint,
    R32G32B32A32Sint,
    R32G32B32A32Sfloat,
    D16Unorm,
    D24UnormS8Uint,
    X8D24UnormPack32,
    D32Sfloat,
    D32SfloatS8UintX24,
    B10G11R11UfloatPack32,
    E5B9G9R9UfloatPack32,
    D24UnormS8Uint,
}

VertexInputRate :: enum {
    Vertex,
    Instance,
}

PolygonMode :: enum {
    Fill,
    Line,
    Point,
}

PrimitiveTopology :: enum {
    PointList,
    LineList,
    LineStrip,
    TriangleList,
    TriangleStrip,
    TriangleFan,
    LineListWithAdjacency,
    LineStripWithAdjacency,
    TriangleListWithAdjacency,
    TriangleStripWithAdjacency,
    PatchList,
}

SampleCountFlag :: enum {
    Flag1,
    Flag2,
    Flag4,
    Flag8,
    Flag16,
    Flag32,
    Flag64,
}

LogicOp :: enum {
    Clear,
    And,
    AndReverse,
    Copy,
    AndInverted,
    NoOp,
    Xor,
    Or,
    Nor,
    Equivalent,
    Invert,
    OrReverse,
    CopyInverted,
    OrInverted,
    Nand,
    Set,
}

AccessFlag :: enum {
    IndirectCommandRead,
    IndexRead,
    VertexAttributeRead,
    UniformRead,
    InputAttachmentRead,
    ShaderRead,
    ShaderWrite,
    ColorAttachmentRead,
    ColorAttachmentWrite,
    DepthStencilAttachmentRead,
    DepthStencilAttachmentWrite,
    TransferRead,
    TransferWrite,
    HostRead,
    HostWrite,
    MemoryRead,
    MemoryWrite,
}

AttachmentLoadOp :: enum {
    Load,
    Clear,
    DontCare,
}

AttachmentStoreOp :: enum {
    Store,
    DontCare,
}

ColorComponentFlag :: enum {
    R,
    G,
    B,
    A,
}

DepthStencilState :: struct {
    depth_test_enable: bool,
    depth_write_enable: bool,
    depth_compare_op: CompareOp,
    depth_bounds_test_enable: bool,
    stencil_test_enable: bool,
    front_fail_op: StencilOp,
    front_pass_op: StencilOp,
    front_depthfail_op: StencilOp,
    front_compare_op: CompareOp,
    front_compare_mask: u32,
    front_write_mask: u32,
    front_reference: u32,
    back_fail_op: StencilOp,
    back_pass_op: StencilOp,
    back_depthfail_op: StencilOp,
    back_compare_op: CompareOp,
    back_compare_mask: u32,
    back_write_mask: u32,
    back_reference: u32,
}

DefaultDepthStencilState :: proc() -> DepthStencilState {
    return DepthStencilState{
        depth_test_enable = true,
        depth_write_enable = true,
        depth_compare_op = CompareOp.Less,
    }
}

ColorBlendState :: struct {
    enable: bool,
    src_color_blend_factor: BlendFactor,
    dst_color_blend_factor: BlendFactor,
    color_blend_op: BlendOp,
    src_alpha_blend_factor: BlendFactor,
    dst_alpha_blend_factor: BlendFactor,
    alpha_blend_op: BlendOp,
    color_write_mask: u32,
}

DefaultColorBlendState :: proc() -> ColorBlendState {
    return ColorBlendState{
        enable = false,
        src_color_blend_factor = BlendFactor.One,
        dst_color_blend_factor = BlendFactor.Zero,
        color_blend_op = BlendOp.Add,
        src_alpha_blend_factor = BlendFactor.One,
        dst_alpha_blend_factor = BlendFactor.Zero,
        alpha_blend_op = BlendOp.Add,
        color_write_mask = 0xf,
    }
}

VertexAttribute :: struct {
    location: u32,
    binding: u32,
    format: Format,
    offset: u32,
}

VertexBinding :: struct {
    binding: u32,
    stride: u32,
    input_rate: VertexInputRate,
}

PipelineVertexState :: struct {
    attributes: []VertexAttribute,
    bindings: []VertexBinding,
}

InputAssemblyState :: struct {
    topology: PrimitiveTopology,
    primitive_restart_enable: bool,
}

DefaultInputAssembly :: proc() -> InputAssemblyState {
    return InputAssemblyState{
        topology = PrimitiveTopology.TriangleList,
        primitive_restart_enable = false,
    }
}

RasterizationState :: struct {
    polygon_mode: PolygonMode,
    cull_mode: CullModeFlag,
    front_face: CullModeFlag,
    depth_clamp_enable: bool,
    depth_bias_enable: bool,
    depth_bias_constant_factor: f32,
    depth_bias_clamp: f32,
    depth_bias_slope_factor: f32,
    line_width: f32,
}

DefaultRasterizationState :: proc() -> RasterizationState {
    return RasterizationState{
        polygon_mode = PolygonMode.Fill,
        cull_mode = CullModeFlag.Back,
        front_face = CullModeFlag.CounterClockwise,
        depth_clamp_enable = false,
        depth_bias_enable = false,
        line_width = 1.0,
    }
}

Viewport :: struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    min_depth: f32,
    max_depth: f32,
}

Scissor :: struct {
    x: i32,
    y: i32,
    width: u32,
    height: u32,
}

DynamicState :: struct {
    viewports: []Viewport,
    scissors: []Scissor,
}

DepthStencilAttachment :: struct {
    format: Format,
    samples: SampleCountFlag,
    load_op: AttachmentLoadOp,
    store_op: AttachmentStoreOp,
    layout: ImageLayout,
    initial_layout: ImageLayout,
    final_layout: ImageLayout,
}

ColorAttachment :: struct {
    format: Format,
    samples: SampleCountFlag,
    load_op: AttachmentLoadOp,
    store_op: AttachmentStoreOp,
    layout: ImageLayout,
    initial_layout: ImageLayout,
    final_layout: ImageLayout,
}

RenderPassAttachment :: struct {
    format: Format,
    samples: SampleCountFlag,
    load_op: AttachmentLoadOp,
    store_op: AttachmentStoreOp,
    stencil_load_op: AttachmentLoadOp,
    stencil_store_op: AttachmentStoreOp,
    initial_layout: ImageLayout,
    final_layout: ImageLayout,
}

SubpassDependency :: struct {
    src_subpass: u32,
    dst_subpass: u32,
    src_stage_mask: PipelineStageFlag,
    dst_stage_mask: PipelineStageFlag,
    src_access_mask: AccessFlag,
    dst_access_mask: AccessFlag,
}

DefaultSubpassDependency :: proc() -> SubpassDependency {
    return SubpassDependency{
        src_subpass = 0xffffffff,
        dst_subpass = 0,
        src_stage_mask = PipelineStageFlag.ColorAttachmentOutput,
        dst_stage_mask = PipelineStageFlag.ColorAttachmentOutput,
        src_access_mask = AccessFlag.ColorAttachmentWrite,
        dst_access_mask = AccessFlag.ColorAttachmentRead,
    }
}

SubpassDescription :: struct {
    pipeline_bind_point: PipelineStageFlag,
    color_attachments: []u32,
    depth_stencil_attachment: u32,
}

DefaultSubpassDescription :: proc() -> SubpassDescription {
    return SubpassDescription{
        pipeline_bind_point = PipelineStageFlag.AllGraphics,
    }
}

RenderPassDescription :: struct {
    attachments: []RenderPassAttachment,
    subpasses: []SubpassDescription,
    dependencies: []SubpassDependency,
}

Vertex3D :: struct {
    position: camera.Vec3,
    color: camera.Vec3,
    normal: camera.Vec3,
    uv: camera.Vec2,
}

Mesh3D :: struct {
    vertices: []Vertex3D,
    indices: []u32,
    vertex_buffer: u64,
    index_buffer: u64,
    vao: u64,
}

InitMesh :: proc() -> Mesh3D {
    return Mesh3D{}
}

FreeMesh :: proc(mesh: ^Mesh3D) {
    mem.free(mesh.vertices)
    mem.free(mesh.indices)
    mesh.vertices = nil
    mesh.indices = nil
}

SimpleCubeMesh :: proc() -> Mesh3D {
    verts := []Vertex3D{
        {position = {-1, -1,  1}, color = {1, 1, 1}, normal = {0, 0, 1}, uv = {0, 0}},
        {position = { 1, -1,  1}, color = {1, 1, 1}, normal = {0, 0, 1}, uv = {1, 0}},
        {position = { 1,  1,  1}, color = {1, 1, 1}, normal = {0, 0, 1}, uv = {1, 1}},
        {position = {-1,  1,  1}, color = {1, 1, 1}, normal = {0, 0, 1}, uv = {0, 1}},
        
        {position = {-1, -1, -1}, color = {1, 0, 0}, normal = {0, 0, -1}, uv = {0, 0}},
        {position = {-1,  1, -1}, color = {1, 0, 0}, normal = {0, 0, -1}, uv = {1, 0}},
        {position = { 1,  1, -1}, color = {1, 0, 0}, normal = {0, 0, -1}, uv = {1, 1}},
        {position = { 1, -1, -1}, color = {1, 0, 0}, normal = {0, 0, -1}, uv = {0, 1}},
        
        {position = {-1,  1, -1}, color = {0, 1, 0}, normal = {0, 1, 0}, uv = {0, 0}},
        {position = {-1,  1,  1}, color = {0, 1, 0}, normal = {0, 1, 0}, uv = {1, 0}},
        {position = { 1,  1,  1}, color = {0, 1, 0}, normal = {0, 1, 0}, uv = {1, 1}},
        {position = { 1,  1, -1}, color = {0, 1, 0}, normal = {0, 1, 0}, uv = {0, 1}},
        
        {position = {-1, -1, -1}, color = {0, 0, 1}, normal = {0, -1, 0}, uv = {0, 0}},
        {position = { 1, -1, -1}, color = {0, 0, 1}, normal = {0, -1, 0}, uv = {1, 0}},
        {position = { 1, -1,  1}, color = {0, 0, 1}, normal = {0, -1, 0}, uv = {1, 1}},
        {position = {-1, -1,  1}, color = {0, 0, 1}, normal = {0, -1, 0}, uv = {0, 1}},
        
        {position = { 1, -1, -1}, color = {1, 0.5, 0}, normal = {1, 0, 0}, uv = {0, 0}},
        {position = { 1,  1, -1}, color = {1, 0.5, 0}, normal = {1, 0, 0}, uv = {1, 0}},
        {position = { 1,  1,  1}, color = {1, 0.5, 0}, normal = {1, 0, 0}, uv = {1, 1}},
        {position = { 1, -1,  1}, color = {1, 0.5, 0}, normal = {1, 0, 0}, uv = {0, 1}},
        
        {position = {-1, -1, -1}, color = {1, 0, 1}, normal = {-1, 0, 0}, uv = {0, 0}},
        {position = {-1, -1,  1}, color = {1, 0, 1}, normal = {-1, 0, 0}, uv = {1, 0}},
        {position = {-1,  1,  1}, color = {1, 0, 1}, normal = {-1, 0, 0}, uv = {1, 1}},
        {position = {-1,  1, -1}, color = {1, 0, 1}, normal = {-1, 0, 0}, uv = {0, 1}},
    }
    
    inds := []u32{
        0, 1, 2, 2, 3, 0,
        4, 5, 6, 6, 7, 4,
        8, 9, 10, 10, 11, 8,
        12, 13, 14, 14, 15, 12,
        16, 17, 18, 18, 19, 16,
        20, 21, 22, 22, 23, 20,
    }
    
    mesh := Mesh3D{
        vertices = mem.slice_clone(verts),
        indices = mem.slice_clone(inds),
    }
    
    return mesh
}

SimplePlaneMesh :: proc(width, depth: f32, segments: int) -> Mesh3D {
    verts := make([]Vertex3D, (segments + 1) * (segments + 1))
    inds := make([]u32, segments * segments * 6)
    
    step_x := width / f32(segments)
    step_z := depth / f32(segments)
    
    for z := 0; z <= segments; z += 1 {
        for x := 0; x <= segments; x += 1 {
            idx := z * (segments + 1) + x
            verts[idx] = Vertex3D{
                position = {
                    x = -width/2 + f32(x) * step_x,
                    y = 0,
                    z = -depth/2 + f32(z) * step_z,
                },
                color = {0.3, 0.5, 0.2},
                normal = {0, 1, 0},
                uv = {
                    x = f32(x) / f32(segments),
                    y = f32(z) / f32(segments),
                },
            }
        }
    }
    
    idx := 0
    for z := 0; z < segments; z += 1 {
        for x := 0; x < segments; x += 1 {
            top_left := u32(z * (segments + 1) + x)
            top_right := top_left + 1
            bottom_left := u32((z + 1) * (segments + 1) + x)
            bottom_right := bottom_left + 1
            
            inds[idx] = top_left
            inds[idx + 1] = bottom_left
            inds[idx + 2] = top_right
            inds[idx + 3] = top_right
            inds[idx + 4] = bottom_left
            inds[idx + 5] = bottom_right
            idx += 6
        }
    }
    
    return Mesh3D{
        vertices = verts,
        indices = inds,
    }
}

SimpleQuadMesh :: proc() -> Mesh3D {
    verts := []Vertex3D{
        {position = {-1, -1, 0}, color = {1, 1, 1}, normal = {0, 0, 1}, uv = {0, 0}},
        {position = { 1, -1, 0}, color = {1, 1, 1}, normal = {0, 0, 1}, uv = {1, 0}},
        {position = { 1,  1, 0}, color = {1, 1, 1}, normal = {0, 0, 1}, uv = {1, 1}},
        {position = {-1,  1, 0}, color = {1, 1, 1}, normal = {0, 0, 1}, uv = {0, 1}},
    }
    
    inds := []u32{0, 1, 2, 2, 3, 0}
    
    return Mesh3D{
        vertices = mem.slice_clone(verts),
        indices = mem.slice_clone(inds),
    }
}

SimpleSkyboxMesh :: proc() -> Mesh3D {
    return SimpleCubeMesh()
}

VulkanRenderer :: struct {
    initialized: bool
    width: int
    height: int
    
    render_pass: u64
    
    depth_format: Format
    color_format: Format
    
    frame_buffer: u64
    depth_image: u64
    depth_view: u64
    color_image: u64
    color_view: u64
    
    viewport: Viewport
    scissor: Scissor
    
    camera: camera.Camera
    camera_input: camera.CameraInputState
    
    meshes: []Mesh3D
    
    skybox_enabled: bool
    wireframe_enabled: bool
    
    clear_color: camera.Vec3
    clear_depth: f32
}

InitVulkanRenderer :: proc() -> VulkanRenderer {
    return VulkanRenderer{
        initialized = false,
        width = 1280,
        height = 720,
        clear_color = {0.1, 0.15, 0.2},
        clear_depth = 1.0,
    }
}

InitVulkanRendererWithSize :: proc(width, height: int) -> VulkanRenderer {
    ren := InitVulkanRenderer()
    ren.width = width
    ren.height = height
    ren.viewport = Viewport{0, 0, f32(width), f32(height), 0.0, 1.0}
    ren.scissor = Scissor{0, 0, u32(width), u32(height)}
    ren.camera = camera.InitCamera()
    camera.SetAspectRatio(&ren.camera, width, height)
    return ren
}

ShutdownVulkanRenderer :: proc(ren: ^VulkanRenderer) {
    for i := 0; i < len(ren.meshes); i += 1 {
        FreeMesh(&ren.meshes[i])
    }
    mem.free(ren.meshes)
    ren.meshes = nil
    ren.initialized = false
}

ResizeVulkanRenderer :: proc(ren: ^VulkanRenderer, width, height: int) {
    ren.width = width
    ren.height = height
    ren.viewport = Viewport{0, 0, f32(width), f32(height), 0.0, 1.0}
    ren.scissor = Scissor{0, 0, u32(width), u32(height)}
    camera.SetAspectRatio(&ren.camera, width, height)
}

BeginFrame :: proc(ren: ^VulkanRenderer) {
}

EndFrame :: proc(ren: ^VulkanRenderer) {
}

RenderTerrain :: proc(ren: ^VulkanRenderer, terrain_data: rawptr) {
}

RenderSkybox :: proc(ren: ^VulkanRenderer) {
    if !ren.skybox_enabled {
        return
    }
}

RenderModels :: proc(ren: ^VulkanRenderer, model_data: rawptr) {
}

RenderWindows3D :: proc(ren: ^VulkanRenderer, windows: rawptr, camera: camera.Camera) {
}

GetCamera :: proc(ren: ^VulkanRenderer) -> ^camera.Camera {
    return &ren.camera
}

GetCameraInput :: proc(ren: ^VulkanRenderer) -> ^camera.CameraInputState {
    return &ren.camera_input
}

UpdateVulkanCamera :: proc(ren: ^VulkanRenderer, dt: f32) {
    camera.UpdateCameraInput(&ren.camera, &ren.camera_input, dt)
}

CalcWindowPlacement :: proc(ren: ^VulkanRenderer, distance: f32) -> camera.WindowPlacement {
    return camera.CalcWindowPlacement(ren.camera, distance)
}

GetCameraDebugInfo :: proc(ren: ^VulkanRenderer) -> string {
    return camera.GetCameraDebugString(ren.camera)
}

RendererInfo :: struct {
    name: string
    driver_version: string
    vendor: string
    api_version: string
    enabled_extensions: []string
}

GetRendererInfo :: proc(ren: ^VulkanRenderer) -> RendererInfo {
    return RendererInfo{
        name = "Vulkan Software Renderer (Stub)",
        driver_version = "1.0",
        vendor = "Software",
        api_version = "1.0.0",
        enabled_extensions = []string{},
    }
}