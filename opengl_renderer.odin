package game_desktop

import "core:fmt"
import "core:math"
import "core:mem"

OpenGLRenderer :: struct {
    initialized: bool,
    width: int,
    height: int,
    
    camera: camera.Camera,
    camera_input: camera.CameraInputState,
    
    default_framebuffer: u32,
    
    depth_texture: u32,
    color_texture: u32,
    
    meshes: []GPUMesh,
    textures: []GPUTexture,
    
    skybox: Skybox,
    skybox_enabled: bool,
    
    wireframe: bool,
    cull_face: bool,
    
    ambient: camera.Vec3,
    lights: []GPULight,
    
    clear_color: camera.Vec4,
    clear_depth: f32,
}

GPUTexture :: struct {
    id: u32,
    width: u32,
    height: u32,
    format: u32,
    target: u32,
}

GPUMesh :: struct {
    vao: u32,
    vbo: u32,
    ibo: u32,
    index_count: u32,
    vertex_count: u32,
    
    position_buffer: u32,
    normal_buffer: u32,
    uv_buffer: u32,
    color_buffer: u32,
    index_buffer: u32,
}

GPUBuffer :: struct {
    id: u32,
    size: u64,
    target: u32,
    usage: u32,
}

GPUShader :: struct {
    program: u32,
    vertex_shader: u32,
    fragment_shader: u32,
    
    uniform_projection: i32,
    uniform_view: i32,
    uniform_model: i32,
    uniform_camera_pos: i32,
    uniform_ambient: i32,
    
    uniform_light_positions: i32,
    uniform_light_colors: i32,
    uniform_light_count: i32,
}

GPULight :: struct {
    position: camera.Vec3,
    color: camera.Vec3,
    intensity: f32,
}

Skybox :: struct {
    cubemap: u32,
    shader: GPUShader,
}

Vec4 :: struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
}

InitOpenGLRenderer :: proc() -> OpenGLRenderer {
    return OpenGLRenderer{
        initialized = false,
        width = 1280,
        height = 720,
        camera = camera.InitCamera(),
        clear_color = {0.1, 0.12, 0.18, 1.0},
        clear_depth = 1.0,
    }
}

InitOpenGLRendererWithSize :: proc(width, height: int) -> OpenGLRenderer {
    ren := InitOpenGLRenderer()
    ren.width = width
    ren.height = height
    camera.SetAspectRatio(&ren.camera, width, height)
    return ren
}

ShutdownOpenGLRenderer :: proc(ren: ^OpenGLRenderer) {
    for i := 0; i < len(ren.meshes); i += 1 {
        FreeGPUMesh(&ren.meshes[i])
    }
    mem.free(ren.meshes)
    ren.meshes = nil
    ren.initialized = false
}

begin :: proc(ren: ^OpenGLRenderer) {
    ClearColor(ren.clear_color.x, ren.clear_color.y, ren.clear_color.z, ren.clear_color.w)
    ClearDepth(ren.clear_depth)
    Clear(CLEAR_COLOR | CLEAR_DEPTH)
    
    if ren.wireframe {
        PolygonMode(FRONT_AND_BACK, LINE)
    } else {
        PolygonMode(FRONT_AND_BACK, FILL)
    }
    
    if ren.cull_face {
        Enable(CULL_FACE)
    } else {
        Disable(CULL_FACE)
    }
    
    Enable(DEPTH_TEST)
    Enable(BLEND)
    BlendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA)
}

end :: proc(ren: ^OpenGLRenderer) {
}

ClearColor :: proc(r, g, b, a: f32) {
    glClearColor(r, g, b, a)
}

ClearDepth :: proc(depth: f32) {
    glClearDepthf(depth)
}

Clear :: proc(mask: u32) {
    glClear(mask)
}

Enable :: proc(cap: u32) {
    glEnable(cap)
}

Disable :: proc(cap: u32) {
    glDisable(cap)
}

PolygonMode :: proc(face, mode: u32) {
    glPolygonMode(face, mode)
}

BlendFunc :: proc(sfactor, dfactor: u32) {
    glBlendFunc(sfactor, dfactor)
}

Viewport :: proc(x, y, w, h: i32) {
    glViewport(x, y, w, h)
}

ResizeOpenGLRenderer :: proc(ren: ^OpenGLRenderer, width, height: int) {
    ren.width = width
    ren.height = height
    Viewport(0, 0, i32(width), i32(height))
    camera.SetAspectRatio(&ren.camera, width, height)
}

CreateSimpleCubeMesh :: proc() -> GPUMesh {
    vertices := []f32{
         1,  1,  1,   -1,  1,  1,   -1, -1,  1,    1, -1,  1,
        -1,  1, -1,    1,  1, -1,    1, -1, -1,   -1, -1, -1,
         1,  1,  1,    1, -1,  1,    1, -1, -1,    1,  1, -1,
        -1,  1,  1,   -1, -1, -1,   -1, -1,  1,   -1,  1, -1,
         1, -1,  1,   -1, -1,  1,   -1, -1, -1,    1, -1, -1,
        -1,  1, -1,    1,  1, -1,    1,  1,  1,   -1,  1,  1,
    }
    
    normals := []f32{
        0,  0,  1,   0,  0,  1,   0,  0,  1,   0,  0,  1,
        0,  0, -1,   0,  0, -1,   0,  0, -1,   0,  0, -1,
        1,  0,  0,   1,  0,  0,   1,  0,  0,   1,  0,  0,
       -1,  0,  0,  -1,  0,  0,  -1,  0,  0,  -1,  0,  0,
        0, -1,  0,   0, -1,  0,   0, -1,  0,   0, -1,  0,
        0,  1,  0,   0,  1,  0,   0,  1,  0,   0,  1,  0,
    }
    
    uvs := []f32{
        0, 0,  1, 0,  1, 1,  0, 1,
        0, 0,  1, 0,  1, 1,  0, 1,
        0, 0,  1, 0,  1, 1,  0, 1,
        0, 0,  1, 0,  1, 1,  0, 1,
        0, 0,  1, 0,  1, 1,  0, 1,
        0, 0,  1, 0,  1, 1,  0, 1,
    }
    
    indices := []u32{
        0, 1, 2, 2, 3, 0,
        4, 5, 6, 6, 7, 4,
        8, 9, 10, 10, 11, 8,
        12, 13, 14, 14, 15, 12,
        16, 17, 18, 18, 19, 16,
        20, 21, 22, 22, 23, 20,
    }
    
    cube := GPUMesh{
        vertex_count = 24,
        index_count = 36,
    }
    
    glGenVertexArrays(1, &cube.vao)
    glBindVertexArray(cube.vao)
    
    glGenBuffers(1, &cube.vbo)
    glBindBuffer(ARRAY_BUFFER, cube.vbo)
    glBufferData(ARRAY_BUFFER, u64(len(vertices) * 4), &vertices[0], STATIC_DRAW)
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0, 3, FLOAT, FALSE, 0, nil)
    
    glGenBuffers(1, &cube.normal_buffer)
    glBindBuffer(ARRAY_BUFFER, cube.normal_buffer)
    glBufferData(ARRAY_BUFFER, u64(len(normals) * 4), &normals[0], STATIC_DRAW)
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(1, 3, FLOAT, FALSE, 0, nil)
    
    glGenBuffers(1, &cube.uv_buffer)
    glBindBuffer(ARRAY_BUFFER, cube.uv_buffer)
    glBufferData(ARRAY_BUFFER, u64(len(uvs) * 4), &uvs[0], STATIC_DRAW)
    glEnableVertexAttribArray(2)
    glVertexAttribPointer(2, 2, FLOAT, FALSE, 0, nil)
    
    glGenBuffers(1, &cube.ibo)
    glBindBuffer(ELEMENT_ARRAY_BUFFER, cube.ibo)
    glBufferData(ELEMENT_ARRAY_BUFFER, u64(len(indices) * 4), &indices[0], STATIC_DRAW)
    
    glBindVertexArray(0)
    
    return cube
}

FreeGPUMesh :: proc(mesh: ^GPUMesh) {
    if mesh.vao != 0 {
        glDeleteVertexArrays(1, &mesh.vao)
    }
    if mesh.vbo != 0 {
        glDeleteBuffers(1, &mesh.vbo)
    }
    if mesh.ibo != 0 {
        glDeleteBuffers(1, &mesh.ibo)
    }
    if mesh.normal_buffer != 0 {
        glDeleteBuffers(1, &mesh.normal_buffer)
    }
    if mesh.uv_buffer != 0 {
        glDeleteBuffers(1, &mesh.uv_buffer)
    }
}

DrawGPUMesh :: proc(mesh: GPUMesh) {
    glBindVertexArray(mesh.vao)
    glDrawElements(TRIANGLES, i32(mesh.index_count), UNSIGNED_INT, nil)
    glBindVertexArray(0)
}

CreateTerrainMesh :: proc(grid_size, cell_size: i32) -> GPUMesh {
    vertex_count := grid_size * grid_size
    index_count := (grid_size - 1) * (grid_size - 1) * 6
    
    vertices := make([]f32, vertex_count * 3)
    normals := make([]f32, vertex_count * 3)
    uvs := make([]f32, vertex_count * 2)
    indices := make([]u32, index_count)
    
    for z := 0; z < grid_size; z += 1 {
        for x := 0; x < grid_size; x += 1 {
            idx := (z * grid_size + x)
            vertices[idx * 3 + 0] = f32(x - grid_size / 2) * f32(cell_size)
            vertices[idx * 3 + 1] = 0
            vertices[idx * 3 + 2] = f32(z - grid_size / 2) * f32(cell_size)
            
            normals[idx * 3 + 0] = 0
            normals[idx * 3 + 1] = 1
            normals[idx * 3 + 2] = 0
            
            uvs[idx * 2 + 0] = f32(x) / f32(grid_size)
            uvs[idx * 2 + 1] = f32(z) / f32(grid_size)
        }
    }
    
    idx: u32 = 0
    for z := 0; z < grid_size - 1; z += 1 {
        for x := 0; x < grid_size - 1; x += 1 {
            tl := u32(z * grid_size + x)
            tr := tl + 1
            bl := tl + u32(grid_size)
            br := bl + 1
            
            indices[idx] = tl
            indices[idx + 1] = bl
            indices[idx + 2] = tr
            indices[idx + 3] = tr
            indices[idx + 4] = bl
            indices[idx + 5] = br
            idx += 6
        }
    }
    
    terrain := GPUMesh{
        vertex_count = u32(vertex_count),
        index_count = u32(index_count),
    }
    
    glGenVertexArrays(1, &terrain.vao)
    glBindVertexArray(terrain.vao)
    
    glGenBuffers(1, &terrain.vbo)
    glBindBuffer(ARRAY_BUFFER, terrain.vbo)
    glBufferData(ARRAY_BUFFER, u64(len(vertices) * 4), &vertices[0], STATIC_DRAW)
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0, 3, FLOAT, FALSE, 0, nil)
    
    glGenBuffers(1, &terrain.normal_buffer)
    glBindBuffer(ARRAY_BUFFER, terrain.normal_buffer)
    glBufferData(ARRAY_BUFFER, u64(len(normals) * 4), &normals[0], STATIC_DRAW)
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(1, 3, FLOAT, FALSE, 0, nil)
    
    glGenBuffers(1, &terrain.uv_buffer)
    glBindBuffer(ARRAY_BUFFER, terrain.uv_buffer)
    glBufferData(ARRAY_BUFFER, u64(len(uvs) * 4), &uvs[0], STATIC_DRAW)
    glEnableVertexAttribArray(2)
    glVertexAttribPointer(2, 2, FLOAT, FALSE, 0, nil)
    
    glGenBuffers(1, &terrain.ibo)
    glBindBuffer(ELEMENT_ARRAY_BUFFER, terrain.ibo)
    glBufferData(ELEMENT_ARRAY_BUFFER, u64(len(indices) * 4), &indices[0], STATIC_DRAW)
    
    glBindVertexArray(0)
    
    mem.free(vertices)
    mem.free(normals)
    mem.free(uvs)
    mem.free(indices)
    
    return terrain
}

CreateShader :: proc(vertex_src, fragment_src: string) -> GPUShader {
    shader := GPUShader{}
    
    shader.vertex_shader = glCreateShader(VERTEX_SHADER)
    glShaderSource(shader.vertex_shader, 1, &vertex_src, nil)
    glCompileShader(shader.vertex_shader)
    
    log: i32 = 0
    glGetShaderiv(shader.vertex_shader, COMPILE_STATUS, &log)
    if log == 0 {
        info_log := make([]u8, 512)
        glGetShaderInfoLog(shader.vertex_shader, 512, nil, &info_log[0])
        fmt.println("Vertex shader error:", string(info_log))
        mem.free(info_log)
    }
    
    shader.fragment_shader = glCreateShader(FRAGMENT_SHADER)
    glShaderSource(shader.fragment_shader, 1, &fragment_src, nil)
    glCompileShader(shader.fragment_shader)
    
    glGetShaderiv(shader.fragment_shader, COMPILE_STATUS, &log)
    if log == 0 {
        info_log := make([]u8, 512)
        glGetShaderInfoLog(shader.fragment_shader, 512, nil, &info_log[0])
        fmt.println("Fragment shader error:", string(info_log))
        mem.free(info_log)
    }
    
    shader.program = glCreateProgram()
    glAttachShader(shader.program, shader.vertex_shader)
    glAttachShader(shader.program, shader.fragment_shader)
    glLinkProgram(shader.program)
    
    glGetProgramiv(shader.program, LINK_STATUS, &log)
    if log == 0 {
        info_log := make([]u8, 512)
        glGetProgramInfoLog(shader.program, 512, nil, &info_log[0])
        fmt.println("Program link error:", string(info_log))
        mem.free(info_log)
    }
    
    shader.uniform_projection = glGetUniformLocation(shader.program, "projection")
    shader.uniform_view = glGetUniformLocation(shader.program, "view")
    shader.uniform_model = glGetUniformLocation(shader.program, "model")
    shader.uniform_camera_pos = glGetUniformLocation(shader.program, "cameraPos")
    shader.uniform_ambient = glGetUniformLocation(shader.program, "ambient")
    
    glDeleteShader(shader.vertex_shader)
    glDeleteShader(shader.fragment_shader)
    
    return shader
}

UseShader :: proc(shader: GPUShader) {
    glUseProgram(shader.program)
}

SetShaderMatrix :: proc(shader: GPUShader, name: string, m: ^f32) {
    loc := glGetUniformLocation(shader.program, name)
    if loc >= 0 {
        glUniformMatrix4fv(loc, 1, FALSE, m)
    }
}

SetShaderVec3 :: proc(shader: GPUShader, name: string, v: camera.Vec3) {
    loc := glGetUniformLocation(shader.program, name)
    if loc >= 0 {
        glUniform3f(loc, v.x, v.y, v.z)
    }
}

SetShaderFloat :: proc(shader: GPUShader, name: string, v: f32) {
    loc := glGetUniformLocation(shader.program, name)
    if loc >= 0 {
        glUniform1f(loc, v)
    }
}

DefaultVertexShader :: proc() -> string {
    return `#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aTex;

out vec3 FragPos;
out vec3 Normal;
out vec2 TexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    FragPos = vec3(model * vec4(aPos, 1.0));
    Normal = mat3(transpose(inverse(model))) * aNormal;
    TexCoord = aTex;
    gl_Position = projection * view * model * vec4(aPos, 1.0);
}`
}

DefaultFragmentShader :: proc() -> string {
    return `#version 330 core
out vec4 FragColor;

in vec3 FragPos;
in vec3 Normal;
in vec2 TexCoord;

uniform vec3 cameraPos;
uniform vec3 ambient;
uniform vec3 lightPositions[4];
uniform vec3 lightColors[4];
uniform int lightCount;

void main() {
    vec3 color = vec3(0.7, 0.8, 0.9);
    vec3 normal = normalize(Normal);
    vec3 viewDir = normalize(cameraPos - FragPos);
    
    vec3 result = ambient * color * 0.3;
    
    for(int i = 0; i < 4 && i < lightCount; i++) {
        vec3 lightDir = normalize(lightPositions[i] - FragPos);
        float diff = max(dot(normal, lightDir), 0.0);
        result += diff * lightColors[i] * color * 0.6;
    }
    
    FragColor = vec4(result, 1.0);
}`
}

SkyboxVertexShader :: proc() -> string {
    return `#version 330 core
layout (location = 0) in vec3 aPos;

out vec3 TexCoords;

uniform mat4 projection;
uniform mat4 view;

void main() {
    TexCoords = aPos;
    vec4 pos = projection * view * vec4(aPos, 1.0);
    gl_Position = pos.xyww;
}`
}

SkyboxFragmentShader :: proc() -> string {
    return `#version 330 core
out vec4 FragColor;

in vec3 TexCoords;

uniform samplerCube skybox;

void main() {
    FragColor = texture(skybox, TexCoords);
}`
}

RenderMesh :: proc(ren: ^OpenGLRenderer, mesh: GPUMesh, model: [^]f32, shader: GPUShader) {
    SetShaderMatrix(shader, "model", model)
    DrawGPUMesh(mesh)
}

RenderTerrain :: proc(ren: ^OpenGLRenderer, terrain: GPUMesh, shader: GPUShader) {
    model := [16]f32{
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
    }
    SetShaderMatrix(shader, "model", &model[0])
    DrawGPUMesh(terrain)
}

RenderSkybox :: proc(skybox: Skybox, view, projection: [^]f32) {
    depth_func := i32(0)
    glGetIntegerv(DEPTH_FUNC, &depth_func)
    
    glDepthFunc(LEQUAL)
    glDepthMask(FALSE)
    
    SetShaderMatrix(skybox.shader, "view", view)
    SetShaderMatrix(skybox.shader, "projection", projection)
    
    glBindVertexArray(skybox.shader.program)
    glDrawArrays(TRIANGLES, 0, 36)
    
    glDepthMask(TRUE)
    glDepthFunc(i32(depth_func))
}

AddLight :: proc(ren: ^OpenGLRenderer, position, color: camera.Vec3, intensity: f32) {
    light := GPULight{
        position = position,
        color = color,
        intensity = intensity,
    }
    ren.lights = append(ren.lights, light)
}

UpdateCamera :: proc(ren: ^OpenGLRenderer, dt: f32) {
    camera.UpdateCameraInput(&ren.camera, &ren.camera_input, dt)
}

GetCamera :: proc(ren: ^OpenGLRenderer) -> ^camera.Camera {
    return &ren.camera
}

GetCameraInput :: proc(ren: ^OpenGLRenderer) -> ^camera.CameraInputState {
    return &ren.camera_input
}

CalcWindowPlacement :: proc(ren: ^OpenGLRenderer, distance: f32) -> camera.WindowPlacement {
    return camera.CalcWindowPlacement(ren.camera, distance)
}

SetClearColor :: proc(ren: ^OpenGLRenderer, r, g, b, a: f32) {
    ren.clear_color = Vec4{r, g, b, a}
}

SetAmbientLight :: proc(ren: ^OpenGLRenderer, color: camera.Vec3) {
    ren.ambient = color
}

ToggleWireframe :: proc(ren: ^OpenGLRenderer) {
    ren.wireframe = !ren.wireframe
}

Info :: struct {
    vendor: string,
    renderer: string,
    version: string,
    glsl_version: string,
}

GetOpenGLInfo :: proc() -> Info {
    vendor := glGetString(VENDOR)
    renderer := glGetString(RENDERER)
    version := glGetString(VERSION)
    glsl := glGetString(SHADING_LANGUAGE_VERSION)
    
    return Info{
        vendor = vendor,
        renderer = renderer,
        version = version,
        glsl_version = glsl,
    }
}

InitOpenGLWithSDL :: proc(window: rawptr) -> bool {
    gl_context := wglGetCurrentContext()
    if gl_context == nil {
        return false
    }
    
    ren := InitOpenGLRenderer()
    ren.initialized = true
    
    info := GetOpenGLInfo()
    fmt.println("OpenGL Renderer:", info.renderer)
    fmt.println("Vendor:", info.vendor)
    fmt.println("Version:", info.version)
    
    return true
}

glEnum :: distinct u32

GL_TEXTURE_CUBE_MAP_POSITIVE_X :: glEnum(0x8515)
GL_VENDOR :: glEnum(0x1F00)
GL_RENDERER :: glEnum(0x1F01)
GL_VERSION :: glEnum(0x1F02)
GL_SHADING_LANGUAGE_VERSION :: glEnum(0x8B8C)

FRONT_AND_BACK :: glEnum(0x0404)
LINE :: glEnum(0x1B01)
FILL :: glEnum(0x1B00)

CULL_FACE :: glEnum(0x0B44)
DEPTH_TEST :: glEnum(0x0B71)
BLEND :: glEnum(0x0BE2)

SRC_ALPHA :: glEnum(0x0302)
ONE_MINUS_SRC_ALPHA :: glEnum(0x0303)

ARRAY_BUFFER :: glEnum(0x8896)
ELEMENT_ARRAY_BUFFER :: glEnum(0x8897)

STATIC_DRAW :: glEnum(0x88E4)

FLOAT :: glEnum(0x1406)

TRUE :: glEnum(1)
FALSE :: glEnum(0)

TRIANGLES :: glEnum(0x0004)

VERTEX_SHADER :: glEnum(0x8B31)
FRAGMENT_SHADER :: glEnum(0x8B30)

COMPILE_STATUS :: glEnum(0x8B81)
LINK_STATUS :: glEnum(0x8B82)

CLEAR_COLOR :: glEnum(0x4000)
CLEAR_DEPTH :: glEnum(0x8001)

UNSIGNED_INT :: glEnum(0x1405)

LEQUAL :: glEnum(0x0203)
DEPTH_FUNC :: glEnum(0x0B44)

DEPTH_MASK :: glEnum(0x0B72)

glGetString :: proc(name: glEnum) -> string {
    return ""
}

glGetIntegerv :: proc(name: glEnum, params: ^i32) {
    params^ = 0
}

glGetUniformLocation :: proc(program: u32, name: string) -> i32 {
    return -1
}

glClearColor :: proc(r, g, b, a: f32) {}

glClearDepthf :: proc(depth: f32) {}

glClear :: proc(mask: u32) {}

glEnable :: proc(cap: u32) {}

glDisable :: proc(cap: u32) {}

glViewport :: proc(x, y, w, h: i32) {}

glPolygonMode :: proc(face, mode: u32) {}

glBlendFunc :: proc(sfactor, dfactor: u32) {}

glCreateShader :: proc(type: u32) -> u32 {
    return 0
}

glShaderSource :: proc(shader: u32, count: i32, string: ^string, length: ^i32) {}

glCompileShader :: proc(shader: u32) {}

glGetShaderiv :: proc(shader: u32, pname: u32, params: ^i32) {}

glGetShaderInfoLog :: proc(shader: u32, maxLength: i32, length: ^i32, infoLog: ^u8) {}

glCreateProgram :: proc() -> u32 {
    return 0
}

glAttachShader :: proc(program, shader: u32) {}

glLinkProgram :: proc(program: u32) {}

glGetProgramiv :: proc(program: u32, pname: u32, params: ^i32) {}

glGetProgramInfoLog :: proc(program: u32, maxLength: i32, length: ^i32, infoLog: ^u32) {}

glUseProgram :: proc(program: u32) {}

glUniformMatrix4fv :: proc(location: i32, count: i32, transpose: u32, value: ^f32) {}

glUniform3f :: proc(location: i32, x, y, z: f32) {}

glUniform1f :: proc(location: i32, v: f32) {}

glGenVertexArrays :: proc(n: i32, arrays: ^u32) {}

glBindVertexArray :: proc(array: u32) {}

glGenBuffers :: proc(n: i32, buffers: ^u32) {}

glBindBuffer :: proc(target: u32, buffer: u32) {}

glBufferData :: proc(target: u32, size: u64, data: rawptr, usage: u32) {}

glEnableVertexAttribArray :: proc(index: u32) {}

glVertexAttribPointer :: proc(index: u32, size: i32, type: u32, normalized: u32, stride: i32, pointer: rawptr) {}

glDrawElements :: proc(mode: u32, count: i32, type: u32, indices: rawptr) {}

glDrawArrays :: proc(mode: u32, first: i32, count: i32) {}

glDeleteVertexArrays :: proc(n: i32, arrays: ^u32) {}

glDeleteBuffers :: proc(n: i32, buffers: ^u32) {}

glDeleteProgram :: proc(program: u32) {}

glDeleteShader :: proc(shader: u32) {}

glDepthMask :: proc(mask: u32) {}

wglGetCurrentContext :: proc() -> rawptr {
    return nil
}