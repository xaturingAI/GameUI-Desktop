package game_desktop

import "core:math"
import "core:fmt"

CameraMode :: enum {
    FirstPerson,
    ThirdPerson,
    Free,
}

Camera :: struct {
    position: Vec3,
    rotation: Vec2,
    fov: f32,
    aspect_ratio: f32,
    near_plane: f32,
    far_plane: f32,
    mode: CameraMode,
    
    move_speed: f32,
    look_sensitivity: f32,
    
    locked: bool,
}

Vec3 :: struct {
    x: f32,
    y: f32,
    z: f32,
}

Vec2 :: struct {
    x: f32,
    y: f32,
}

Mat4 :: struct {
    m: [16]f32,
}

InitCamera :: proc() -> Camera {
    return Camera{
        position = Vec3{0, 2, 5},
        rotation = Vec2{0, 0},
        fov = 70.0,
        aspect_ratio = 16.0 / 9.0,
        near_plane = 0.1,
        far_plane = 1000.0,
        mode = CameraMode.FirstPerson,
        move_speed = 5.0,
        look_sensitivity = 0.15,
        locked = false,
    }
}

SetAspectRatio :: proc(cam: ^Camera, width, height: int) {
    cam.aspect_ratio = f32(width) / f32(height)
}

ProjectionMatrix :: proc(cam: Camera) -> Mat4 {
    f := 1.0 / math.tan(cam.fov * 0.5 * math.PI / 180.0)
    nf := 1.0 / (cam.near_plane - cam.far_plane)
    
    m := Mat4{}
    m.m[0] = f / cam.aspect_ratio
    m.m[5] = f
    m.m[10] = (cam.far_plane + cam.near_plane) * nf
    m.m[11] = -1.0
    m.m[14] = 2.0 * cam.far_plane * cam.near_plane * nf
    
    return m
}

ViewMatrix :: proc(cam: Camera) -> Mat4 {
    pitch := cam.rotation.x * math.PI / 180.0
    yaw := cam.rotation.y * math.PI / 180.0
    
    cp := math.cos(pitch)
    sp := math.sin(pitch)
    cy := math.cos(yaw)
    sy := math.sin(yaw)
    
    m := Mat4{}
    
    m.m[0] = cy
    m.m[2] = -sy
    m.m[4] = sy * sp
    m.m[5] = cp
    m.m[6] = cy * sp
    m.m[8] = sy * cp
    m.m[9] = -sp
    m.m[10] = cy * cp
    
    m.m[12] = -(cy * cam.position.x + sy * cam.position.z)
    m.m[13] = -(sy * sp * cam.position.x + cp * cam.position.y + cy * sp * cam.position.z)
    m.m[14] = -(cy * sp * cam.position.x + cp * cam.position.y - sy * sp * cam.position.z)
    m.m[15] = 1.0
    
    return m
}

ViewProjectionMatrix :: proc(cam: Camera) -> Mat4 {
    proj := ProjectionMatrix(cam)
    view := ViewMatrix(cam)
    return MultiplyMat4(proj, view)
}

MultiplyMat4 :: proc(a, b: Mat4) -> Mat4 {
    m := Mat4{}
    for row := 0; row < 4; row += 1 {
        for col := 0; col < 4; col += 1 {
            sum := 0.0
            for k := 0; k < 4; k += 1 {
                sum += a.m[row * 4 + k] * b.m[k * 4 + col]
            }
            m.m[row * 4 + col] = sum
        }
    }
    return m
}

GetForwardVector :: proc(cam: Camera) -> Vec3 {
    pitch := cam.rotation.x * math.PI / 180.0
    yaw := cam.rotation.y * math.PI / 180.0
    
    return Vec3{
        x = math.cos(pitch) * math.sin(yaw),
        y = -math.sin(pitch),
        z = math.cos(pitch) * math.cos(yaw),
    }
}

GetRightVector :: proc(cam: Camera) -> Vec3 {
    yaw := cam.rotation.y * math.PI / 180.0
    
    return Vec3{
        x = math.cos(yaw),
        y = 0,
        z = -math.sin(yaw),
    }
}

GetUpVector :: proc(cam: Camera) -> Vec3 {
    forward := GetForwardVector(cam)
    right := GetRightVector(cam)
    
    return Vec3{
        x = forward.y * right.z - forward.z * right.y,
        y = forward.z * right.x - forward.x * right.z,
        z = forward.x * right.y - forward.y * right.x,
    }
}

MoveCamera :: proc(cam: ^Camera, direction: Vec3, dt: f32) {
    if cam.locked {
        return
    }
    
    speed := cam.move_speed * dt
    cam.position.x += direction.x * speed
    cam.position.y += direction.y * speed
    cam.position.z += direction.z * speed
}

MoveForward :: proc(cam: ^Camera, dt: f32) {
    forward := GetForwardVector(cam^)
    MoveCamera(cam, forward, dt)
}

MoveBackward :: proc(cam: ^Camera, dt: f32) {
    forward := GetForwardVector(cam^)
    MoveCamera(cam, Vec3{-forward.x, -forward.y, -forward.z}, dt)
}

MoveLeft :: proc(cam: ^Camera, dt: f32) {
    right := GetRightVector(cam^)
    MoveCamera(cam, Vec3{-right.x, -right.y, -right.z}, dt)
}

MoveRight :: proc(cam: ^Camera, dt: f32) {
    right := GetRightVector(cam^)
    MoveCamera(cam, right, dt)
}

MoveUp :: proc(cam: ^Camera, dt: f32) {
    MoveCamera(cam, Vec3{0, 1, 0}, dt)
}

MoveDown :: proc(cam: ^Camera, dt: f32) {
    MoveCamera(cam, Vec3{0, -1, 0}, dt)
}

LookRotation :: proc(cam: ^Camera, dx, dy: f32) {
    if cam.locked {
        return
    }
    
    cam.rotation.y += dx * cam.look_sensitivity
    cam.rotation.x -= dy * cam.look_sensitivity
    
    if cam.rotation.x > 89.0 {
        cam.rotation.x = 89.0
    }
    if cam.rotation.x < -89.0 {
        cam.rotation.x = -89.0
    }
    
    for cam.rotation.y >= 360.0 {
        cam.rotation.y -= 360.0
    }
    for cam.rotation.y < 0.0 {
        cam.rotation.y += 360.0
    }
}

UpdateCamera :: proc(cam: ^Camera, dt: f32) {
}

Ray3D :: struct {
    origin: Vec3,
    direction: Vec3,
}

InitRayFromCamera :: proc(cam: Camera) -> Ray3D {
    return Ray3D{
        origin = cam.position,
        direction = GetForwardVector(cam),
    }
}

InitRayFromScreen :: proc(cam: Camera, screen_x, screen_y: f32, screen_w, screen_h: int) -> Ray3D {
    ndc_x := (2.0 * screen_x / f32(screen_w)) - 1.0
    ndc_y := 1.0 - (2.0 * screen_y / f32(screen_h))
    
    aspect := cam.aspect_ratio
    f := 1.0 / math.tan(cam.fov * 0.5 * math.PI / 180.0)
    
    ray_dir := Vec3{
        x = ndc_x / f,
        y = ndc_y / f * aspect,
        z = -1.0,
    }
    
    mat := ViewMatrix(cam)
    inv_view := TransposeMat4(Mat4{m = mat.m})
    
    world_dir := Vec3{
        x = inv_view.m[0] * ray_dir.x + inv_view.m[4] * ray_dir.y + inv_view.m[8] * ray_dir.z,
        y = inv_view.m[1] * ray_dir.x + inv_view.m[5] * ray_dir.y + inv_view.m[9] * ray_dir.z,
        z = inv_view.m[2] * ray_dir.x + inv_view.m[6] * ray_dir.y + inv_view.m[10] * ray_dir.z,
    }
    
    len := math.sqrt(world_dir.x * world_dir.x + world_dir.y * world_dir.y + world_dir.z * world_dir.z)
    if len > 0.0001 {
        world_dir.x /= len
        world_dir.y /= len
        world_dir.z /= len
    }
    
    return Ray3D{
        origin = cam.position,
        direction = world_dir,
    }
}

TransposeMat4 :: proc(m: Mat4) -> Mat4 {
    t := Mat4{}
    for i := 0; i < 4; i += 1 {
        for j := 0; j < 4; j += 1 {
            t.m[i * 4 + j] = m.m[j * 4 + i]
        }
    }
    return t
}

IntersectPlane :: proc(ray: Ray3D, plane_y: f32) -> Vec3 {
    if math.abs(ray.direction.y) < 0.0001 {
        return Vec3{0, 0, 0}
    }
    
    t := (plane_y - ray.origin.y) / ray.direction.y
    
    return Vec3{
        x = ray.origin.x + ray.direction.x * t,
        y = plane_y,
        z = ray.origin.z + ray.direction.z * t,
    }
}

IntersectPlaneDistance :: proc(ray: Ray3D, plane_y: f32) -> f32 {
    if math.abs(ray.direction.y) < 0.0001 {
        return -1.0
    }
    return (plane_y - ray.origin.y) / ray.direction.y
}

Distance3D :: proc(a, b: Vec3) -> f32 {
    dx := b.x - a.x
    dy := b.y - a.y
    dz := b.z - a.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
}

WindowPlacement :: struct {
    position: Vec3,
    rotation: Vec2,
    distance: f32,
    valid: bool,
}

CalcWindowPlacement :: proc(cam: Camera, distance: f32) -> WindowPlacement {
    placement := WindowPlacement{}
    
    if distance < 0.5 {
        return placement
    }
    
    forward := GetForwardVector(cam)
    
    placement.position = Vec3{
        x = cam.position.x + forward.x * distance,
        y = cam.position.y + forward.y * distance,
        z = cam.position.z + forward.z * distance,
    }
    
    placement.rotation = cam.rotation
    
    dist := distance
    if placement.position.y < 0.1 {
        placement.position.y = 0.1
    }
    
    placement.distance = dist
    placement.valid = true
    
    return placement
}

GetWindowScreenPosition :: proc(cam: Camera, window_pos: Vec3, screen_w, screen_h: int) -> (f32, f32, bool) {
    offset_x := window_pos.x - cam.position.x
    offset_y := window_pos.y - cam.position.y
    offset_z := window_pos.z - cam.position.z
    
    pitch := -cam.rotation.x * math.PI / 180.0
    yaw := -cam.rotation.y * math.PI / 180.0
    
    cp := math.cos(pitch)
    sp := math.sin(pitch)
    cy := math.cos(yaw)
    sy := math.sin(yaw)
    
    transformed_y := cp * offset_y - sp * offset_z
    transformed_z := sp * offset_y + cp * offset_z
    transformed_x := cy * offset_x + sy * transformed_z
    
    if transformed_z >= 0.0 {
        return 0, 0, false
    }
    
    f := 1.0 / math.tan(cam.fov * 0.5 * math.PI / 180.0)
    
    screen_x := f32(screen_w) / 2.0 + (transformed_x / (-transformed_z)) * f32(screen_w) / 2.0 / cam.aspect_ratio
    screen_y := f32(screen_h) / 2.0 - (transformed_y / (-transformed_z)) * f32(screen_h) / 2.0
    
    if screen_x < 0 || screen_x > f32(screen_w) || screen_y < 0 || screen_y > f32(screen_h) {
        return screen_x, screen_y, false
    }
    
    return screen_x, screen_y, true
}

CameraInputState :: struct {
    move_forward: bool,
    move_backward: bool,
    move_left: bool,
    move_right: bool,
    move_up: bool,
    move_down: bool,
    look_dx: f32,
    look_dy: f32,
    mouse_captured: bool,
}

InitCameraInput :: proc() -> CameraInputState {
    return CameraInputState{}
}

UpdateCameraInput :: proc(cam: ^Camera, input: ^CameraInputState, dt: f32) {
    if input.move_forward {
        MoveForward(cam, dt)
    }
    if input.move_backward {
        MoveBackward(cam, dt)
    }
    if input.move_left {
        MoveLeft(cam, dt)
    }
    if input.move_right {
        MoveRight(cam, dt)
    }
    if input.move_up {
        MoveUp(cam, dt)
    }
    if input.move_down {
        MoveDown(cam, dt)
    }
    
    if input.look_dx != 0.0 || input.look_dy != 0.0 {
        LookRotation(cam, input.look_dx, input.look_dy)
        input.look_dx = 0
        input.look_dy = 0
    }
}

SetCameraMouseCaptured :: proc(cam: ^Camera, captured: bool) {
    cam.locked = captured
    if captured {
        cam.move_speed = 8.0
    } else {
        cam.move_speed = 5.0
    }
}

GetCameraDebugString :: proc(cam: Camera) -> string {
    return fmt.sprint("Pos: (", cam.position.x, ", ", cam.position.y, ", ", cam.position.z, ") Rot: (", cam.rotation.x, ", ", cam.rotation.y, ")")
}