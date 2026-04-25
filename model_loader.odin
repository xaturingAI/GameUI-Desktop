package game_desktop

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strings"

ModelLoader :: struct {
    meshes: []LoadedMesh,
    textures: []LoadedTexture,
    materials: []Material,
    animations: []Animation,
}

LoadedTexture :: struct {
    id: u32,
    path: string,
    width: u32,
    height: u32,
    format: u32,
}

Material :: struct {
    name: string,
    diffuse: Vec4,
    specular: Vec3,
    ambient: Vec3,
    shininess: f32,
    diffuse_texture: i32,
    normal_texture: i32,
}

Animation :: struct {
    name: string,
    duration: f32,
    tracks: []AnimationTrack,
}

AnimationTrack :: struct {
    node: i32,
    positions: []KeyframePosition,
    rotations: []KeyframeRotation,
    scales: []KeyframeScale,
}

KeyframePosition :: struct {
    time: f32,
    value: Vec3,
}

KeyframeRotation :: struct {
    time: f32,
    value: Vec4,
}

KeyframeScale :: struct {
    time: f32,
    value: Vec3,
}

Vec4 :: struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
}

Vec3 :: struct {
    x: f32,
    y: f32,
    z: f32,
}

InitModelLoader :: proc() -> ModelLoader {
    return ModelLoader{
        meshes = []LoadedMesh{},
        textures = []LoadedTexture{},
        materials = []Material{},
        animations = []Animation{},
    }
}

FreeModelLoader :: proc(loader: ^ModelLoader) {
    for i := 0; i < len(loader.meshes); i += 1 {
        FreeLoadedMesh(&loader.meshes[i])
    }
    mem.free(loader.meshes)
    loader.meshes = nil
}

LoadedMesh :: struct {
    name: string,
    vertices: []MeshVertex,
    indices: []u32,
    
    vao: u32,
    vbo: u32,
    ibo: u32,
    index_count: u32,
    
    material_id: i32,
}

MeshVertex :: struct {
    position: Vec3,
    normal: Vec3,
    uv: Vec2,
    tangent: Vec3,
    bitangent: Vec3,
    color: Vec4,
}

Mesh :: struct {
    vertices: []MeshVertex,
    indices: []u32,
}

InitLoadedMesh :: proc() -> LoadedMesh {
    return LoadedMesh{
        name = "",
        material_id = -1,
    }
}

FreeLoadedMesh :: proc(mesh: ^LoadedMesh) {
    mem.free(mesh.vertices)
    mem.free(mesh.indices)
    mesh.vertices = nil
    mesh.indices = nil
}

LoadModel :: proc(path: string) -> LoadedMesh {
    mesh := InitLoadedMesh()
    
    ext := GetFileExtension(path)
    
    if ext == ".obj" {
        mesh = LoadOBJ(path)
    } else if ext == ".gltf" || ext == ".glb" {
        mesh = LoadGLTF(path)
    } else if ext == ".dae" {
        mesh = LoadCOLLADA(path)
    } else {
        fmt.println("Unsupported model format:", ext)
    }
    
    mesh.name = GetFileName(path)
    
    return mesh
}

GetFileExtension :: proc(path: string) -> string {
    for i := len(path) - 1; i >= 0; i -= 1 {
        if path[i] == '.' {
            return path[i:]
        }
        if path[i] == '/' || path[i] == '\\' {
            break
        }
    }
    return ""
}

GetFileName :: proc(path: string) -> string {
    name_start := 0
    for i := len(path) - 1; i >= 0; i -= 1 {
        if path[i] == '/' || path[i] == '\\' {
            name_start = i + 1
            break
        }
    }
    
    name_end := len(path)
    for i := name_start; i < len(path); i += 1 {
        if path[i] == '.' {
            name_end = i
            break
        }
    }
    
    return path[name_start:name_end]
}

LoadOBJ :: proc(path: string) -> LoadedMesh {
    mesh := InitLoadedMesh()
    
    data, ok := os.read_entire_file(path)
    if !ok {
        fmt.println("Failed to read file:", path)
        return mesh
    }
    
    positions := []Vec3{}
    normals := []Vec3{}
    uvs := []Vec2{}
    
    vertices := []MeshVertex{}
    indices := []u32{}
    
    lines := strings.split(string(data), "\n")
    
    for i := 0; i < len(lines); i += 1 {
        line := lines[i]
        if len(line) < 2 {
            continue
        }
        
        if line[0] == 'v' && line[1] == ' ' {
            pos := ParseOBJVertex(line[2:])
            positions = append(positions, pos)
        } else if line[0] == 'v' && line[1] == 'n' && line[2] == ' ' {
            norm := ParseOBJNormal(line[3:])
            normals = append(normals, norm)
        } else if line[0] == 'v' && line[1] == 't' && line[2] == ' ' {
            uv := ParseOBJUV(line[3:])
            uvs = append(uvs, uv)
        } else if line[0] == 'f' && line[1] == ' ' {
            face_indices := ParseOBJFace(line[2:], positions, normals, uvs)
            for j := 0; j < len(face_indices); j += 1 {
                fi := face_indices[j]
                vertices = append(vertices, fi)
                indices = append(indices, u32(len(vertices) - 1))
            }
        }
    }
    
    mem.free(data)
    
    mesh.vertices = mem.slice_clone(vertices)
    mesh.indices = mem.slice_clone(indices)
    
    if len(mesh.vertices) > 0 {
        GenerateTangents(&mesh)
    }
    
    return mesh
}

ParseOBJVertex :: proc(s: string) -> Vec3 {
    parts := strings.split(s, " ")
    if len(parts) < 3 {
        return Vec3{0, 0, 0}
    }
    
    x := StringToF32(strings.trim(parts[0], " "))
    y := StringToF32(strings.trim(parts[1], " "))
    z := StringToF32(strings.trim(parts[2], " "))
    
    return Vec3{x = x, y = y, z = z}
}

ParseOBJNormal :: proc(s: string) -> Vec3 {
    parts := strings.split(s, " ")
    if len(parts) < 3 {
        return Vec3{0, 1, 0}
    }
    
    x := StringToF32(strings.trim(parts[0], " "))
    y := StringToF32(strings.trim(parts[1], " "))
    z := StringToF32(strings.trim(parts[2], " "))
    
    return Vec3{x = x, y = y, z = z}
}

ParseOBJUV :: proc(s: string) -> Vec2 {
    parts := strings.split(s, " ")
    if len(parts) < 2 {
        return Vec2{0, 0}
    }
    
    x := StringToF32(strings.trim(parts[0], " "))
    y := StringToF32(strings.trim(parts[1], " "))
    
    return Vec2{x = x, y = y}
}

ParseOBJFace :: proc(s: string, positions: []Vec3, normals: []Vec3, uvs: []Vec2) -> []MeshVertex {
    verts := []MeshVertex{}
    
    face_indices := strings.split(s, " ")
    
    for i := 0; i < len(face_indices); i += 1 {
        fi := face_indices[i]
        parts := strings.split(fi, "/")
        if len(parts) < 1 {
            continue
        }
        
        v := MeshVertex{}
        
        pos_idx := StringToInt(strings.trim(parts[0], " ")) - 1
        if pos_idx >= 0 && pos_idx < len(positions) {
            v.position = positions[pos_idx]
        }
        
        if len(parts) >= 2 && parts[1] != "" {
            uv_idx := StringToInt(strings.trim(parts[1], " ")) - 1
            if uv_idx >= 0 && uv_idx < len(uvs) {
                v.uv = uvs[uv_idx]
            }
        }
        
        if len(parts) >= 3 && parts[2] != "" {
            norm_idx := StringToInt(strings.trim(parts[2], " ")) - 1
            if norm_idx >= 0 && norm_idx < len(normals) {
                v.normal = normals[norm_idx]
            }
        }
        
        v.color = Vec4{1, 1, 1, 1}
        
        verts = append(verts, v)
    }
    
    return verts
}

StringToF32 :: proc(s: string) -> f32 {
    return 0.0
}

StringToInt :: proc(s: string) -> i32 {
    return 0
}

Vec2 :: struct {
    x: f32,
    y: f32,
}

GenerateTangents :: proc(mesh: ^LoadedMesh) {
    if len(mesh.vertices) < 3 || len(mesh.indices) < 3 {
        return
    }
    
    for i := 0; i < len(mesh.indices); i += 3 {
        i0 := mesh.indices[i]
        i1 := mesh.indices[i + 1]
        i2 := mesh.indices[i + 2]
        
        if i0 >= u32(len(mesh.vertices)) || i1 >= u32(len(mesh.vertices)) || i2 >= u32(len(mesh.vertices)) {
            continue
        }
        
        v0 := &mesh.vertices[i0]
        v1 := &mesh.vertices[i1]
        v2 := &mesh.vertices[i2]
        
        delta_pos1 := Vec3{v1.position.x - v0.position.x, v1.position.y - v0.position.y, v1.position.z - v0.position.z}
        delta_pos2 := Vec3{v2.position.x - v0.position.x, v2.position.y - v0.position.y, v2.position.z - v0.position.z}
        
        delta_uv1 := Vec2{v1.uv.x - v0.uv.x, v1.uv.y - v0.uv.y}
        delta_uv2 := Vec2{v2.uv.x - v0.uv.x, v2.uv.y - v0.uv.y}
        
        r := 1.0 / (delta_uv1.x * delta_uv2.y - delta_uv2.x * delta_uv1.y)
        
        tangent := Vec3{
            x = (delta_pos1.x * delta_uv2.y - delta_pos2.x * delta_uv1.y) * r,
            y = (delta_pos1.y * delta_uv2.y - delta_pos2.y * delta_uv1.y) * r,
            z = (delta_pos1.z * delta_uv2.y - delta_pos2.z * delta_uv1.y) * r,
        }
        
        v0.tangent = tangent
        v1.tangent = tangent
        v2.tangent = tangent
    }
}

LoadGLTF :: proc(path: string) -> LoadedMesh {
    mesh := InitLoadedMesh()
    return mesh
}

LoadCOLLADA :: proc(path: string) -> LoadedMesh {
    mesh := InitLoadedMesh()
    return mesh
}

UploadToGPU :: proc(mesh: ^LoadedMesh) {
    mesh.vao = 0
    mesh.vbo = 0
    mesh.ibo = 0
    
    if len(mesh.vertices) == 0 {
        return
    }
    
    mesh.index_count = u32(len(mesh.indices))
    
    glGenVertexArrays(1, &mesh.vao)
    glBindVertexArray(mesh.vao)
    
    glGenBuffers(1, &mesh.vbo)
    glBindBuffer(ARRAY_BUFFER, mesh.vbo)
    glBufferData(ARRAY_BUFFER, u64(len(mesh.vertices) * size_of(MeshVertex)), &mesh.vertices[0], STATIC_DRAW)
    
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0, 3, FLOAT, FALSE, size_of(MeshVertex), cast(rawptr)(offset_of(MeshVertex, position)))
    
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(1, 3, FLOAT, FALSE, size_of(MeshVertex), cast(rawptr)(offset_of(MeshVertex, normal)))
    
    glEnableVertexAttribArray(2)
    glVertexAttribPointer(2, 2, FLOAT, FALSE, size_of(MeshVertex), cast(rawptr)(offset_of(MeshVertex, uv)))
    
    glEnableVertexAttribArray(3)
    glVertexAttribPointer(3, 3, FLOAT, FALSE, size_of(MeshVertex), cast(rawptr)(offset_of(MeshVertex, tangent)))
    
    glEnableVertexAttribArray(4)
    glVertexAttribPointer(4, 2, FLOAT, FALSE, size_of(MeshVertex), cast(rawptr)(offset_of(MeshVertex, bitangent)))
    
    glGenBuffers(1, &mesh.ibo)
    glBindBuffer(ELEMENT_ARRAY_BUFFER, mesh.ibo)
    glBufferData(ELEMENT_ARRAY_BUFFER, u64(len(mesh.indices) * 4), &mesh.indices[0], STATIC_DRAW)
    
    glBindVertexArray(0)
}

DrawMesh :: proc(mesh: LoadedMesh) {
    if mesh.vao == 0 || mesh.index_count == 0 {
        return
    }
    glBindVertexArray(mesh.vao)
    glDrawElements(TRIANGLES, i32(mesh.index_count), UNSIGNED_INT, nil)
    glBindVertexArray(0)
}

FreeMeshGPU :: proc(mesh: ^LoadedMesh) {
    if mesh.vao != 0 {
        glDeleteVertexArrays(1, &mesh.vao)
    }
    if mesh.vbo != 0 {
        glDeleteBuffers(1, &mesh.vbo)
    }
    if mesh.ibo != 0 {
        glDeleteBuffers(1, &mesh.ibo)
    }
    mesh.vao = 0
    mesh.vbo = 0
    mesh.ibo = 0
}

ModelInstance :: struct {
    mesh: ^LoadedMesh,
    transform: Mat4,
    material_id: i32,
    visible: bool,
}

CreateInstance :: proc(mesh: ^LoadedMesh) -> ModelInstance {
    inst := ModelInstance{
        mesh = mesh,
        transform = IdentityMat4(),
        visible = true,
    }
    return inst
}

SetPosition :: proc(instance: ^ModelInstance, x, y, z: f32) {
    instance.transform.m[12] = x
    instance.transform.m[13] = y
    instance.transform.m[14] = z
}

SetScale :: proc(instance: ^ModelInstance, x, y, z: f32) {
    instance.transform.m[0] = x
    instance.transform.m[5] = y
    instance.transform.m[10] = z
}

Mat4 :: struct {
    m: [16]f32
}

IdentityMat4 :: proc() -> Mat4 {
    m := Mat4{}
    m.m[0] = 1
    m.m[5] = 1
    m.m[10] = 1
    m.m[15] = 1
    return m
}

TranslateMat4 :: proc(x, y, z: f32) -> Mat4 {
    m := IdentityMat4()
    m.m[12] = x
    m.m[13] = y
    m.m[14] = z
    return m
}

ScaleMat4 :: proc(x, y, z: f32) -> Mat4 {
    m := IdentityMat4()
    m.m[0] = x
    m.m[5] = y
    m.m[10] = z
    return m
}

RotateMat4XYZ :: proc(x, y, z: f32) -> Mat4 {
    m := IdentityMat4()
    return m
}

MultiplyMat4 :: proc(a, b: Mat4) -> Mat4 {
    result := Mat4{}
    for i := 0; i < 4; i += 1 {
        for j := 0; j < 4; j += 1 {
            sum := 0.0
            for k := 0; k < 4; k += 1 {
                sum += a.m[i * 4 + k] * b.m[k * 4 + j]
            }
            result.m[i * 4 + j] = sum
        }
    }
    return result
}

offset_of :: proc(T: typeid, field: string) -> int {
    return 0
}

cast :: proc($T: typeid) -> rawptr {
    return nil
}

glGenVertexArrays :: proc(n: i32, arrays: ^u32) {}

glBindVertexArray :: proc(array: u32) {}

glGenBuffers :: proc(n: i32, buffers: ^u32) {}

glBindBuffer :: proc(target: u32, buffer: u32) {}

glBufferData :: proc(target: u32, size: u64, data: rawptr, usage: u32) {}

glEnableVertexAttribArray :: proc(index: u32) {}

glVertexAttribPointer :: proc(index: u32, size: i32, type: u32, normalized: u32, stride: i32, pointer: rawptr) {}

glDrawElements :: proc(mode: u32, count: i32, type: u32, indices: rawptr) {}

glDeleteVertexArrays :: proc(n: i32, arrays: ^u32) {}

glDeleteBuffers :: proc(n: i32, buffers: ^u32) {}

size_of :: proc($T: typeid) -> int {
    return 0
}

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

glEnum :: distinct u32