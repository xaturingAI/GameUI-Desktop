package game_desktop

import "core:mem"
import "core:math"
import "camera"
import "model_loader"

Scene :: struct {
    entities: []Entity,
    camera: camera.Camera,
    
    ambient_light: camera.Vec3,
    directional_light: DirectionalLight,
    point_lights: []PointLight,
    
    skybox: Skybox,
    terrain: ^model_loader.LoadedMesh,
    
    gravity: f32,
    terrain_height: f32,
}

Entity :: struct {
    name: string,
    mesh: ^model_loader.LoadedMesh,
    
    position: camera.Vec3,
    rotation: camera.Vec3,
    scale: camera.Vec3,
    
    velocity: camera.Vec3,
    
    visible: bool,
    collidable: bool,
    mass: f32,
    
    entity_type: EntityType,
}

EntityType :: enum {
    Static,
    Dynamic,
    Player,
    NPC,
    Item,
    Projectile,
}

DirectionalLight :: struct {
    direction: camera.Vec3,
    color: camera.Vec3,
    intensity: f32,
    enabled: bool,
}

PointLight :: struct {
    position: camera.Vec3,
    color: camera.Vec3,
    intensity: f32,
    radius: f32,
    enabled: bool,
}

Skybox :: struct {
    cubemap_texture: u32,
    enabled: bool,
}

InitScene :: proc() -> Scene {
    return Scene{
        entities = []Entity{},
        camera = camera.InitCamera(),
        ambient_light = {0.2, 0.2, 0.25},
        directional_light = DirectionalLight{
            direction = {0.5, -1.0, 0.5},
            color = {1.0, 0.95, 0.9},
            intensity = 0.8,
            enabled = true,
        },
        point_lights = []PointLight{},
        gravity = -9.81,
        terrain_height = 0.0,
    }
}

FreeScene :: proc(scene: ^Scene) {
    for i := 0; i < len(scene.entities); i += 1 {
        FreeEntity(&scene.entities[i])
    }
    mem.free(scene.entities)
    scene.entities = nil
}

FreeEntity :: proc(entity: ^Entity) {
    entity.mesh = nil
}

AddEntity :: proc(scene: ^Scene, name: string, mesh: ^model_loader.LoadedMesh) -> int {
    entity := Entity{
        name = name,
        mesh = mesh,
        position = {0, 0, 0},
        rotation = {0, 0, 0},
        scale = {1, 1, 1},
        visible = true,
        collidable = true,
        mass = 1.0,
        entity_type = EntityType.Static,
    }
    scene.entities = append(scene.entities, entity)
    return len(scene.entities) - 1
}

RemoveEntity :: proc(scene: ^Scene, index: int) {
    if index < 0 || index >= len(scene.entities) {
        return
    }
    
    scene.entities[index] = scene.entities[len(scene.entities) - 1]
    scene.entities = scene.entities[:len(scene.entities) - 1]
}

GetEntity :: proc(scene: ^Scene, index: int) -> ^Entity {
    if index < 0 || index >= len(scene.entities) {
        return nil
    }
    return &scene.entities[index]
}

GetEntityByName :: proc(scene: ^Scene, name: string) -> ^Entity {
    for i := 0; i < len(scene.entities); i += 1 {
        if scene.entities[i].name == name {
            return &scene.entities[i]
        }
    }
    return nil
}

UpdateScene :: proc(scene: ^Scene, dt: f32) {
    camera.UpdateCameraInput(&scene.camera, nil, dt)
    
    for i := 0; i < len(scene.entities); i += 1 {
        UpdateEntity(&scene.entities[i], dt)
    }
}

UpdateEntity :: proc(entity: ^Entity, dt: f32) {
    if !entity.visible {
        return
    }
    
    if entity.entity_type == EntityType.Dynamic || entity.entity_type == EntityType.Player {
        entity.velocity.y += -9.81 * dt
        
        entity.position.x += entity.velocity.x * dt
        entity.position.y += entity.velocity.y * dt
        entity.position.z += entity.velocity.z * dt
        
        if entity.position.y < 0 {
            entity.position.y = 0
            entity.velocity.y = 0
        }
    }
}

SetEntityPosition :: proc(entity: ^Entity, pos: camera.Vec3) {
    entity.position = pos
}

SetEntityRotation :: proc(entity: ^Entity, rot: camera.Vec3) {
    entity.rotation = rot
}

SetEntityScale :: proc(entity: ^Entity, s: camera.Vec3) {
    entity.scale = s
}

TranslateEntity :: proc(entity: ^Entity, delta: camera.Vec3) {
    entity.position.x += delta.x
    entity.position.y += delta.y
    entity.position.z += delta.z
}

RotateEntity :: proc(entity: ^Entity, delta: camera.Vec3) {
    entity.rotation.x += delta.x
    entity.rotation.y += delta.y
    entity.rotation.z += delta.z
}

ApplyImpulse :: proc(entity: ^Entity, impulse: camera.Vec3) {
    entity.velocity.x += impulse.x / entity.mass
    entity.velocity.y += impulse.y / entity.mass
    entity.velocity.z += impulse.z / entity.mass
}

Raycast :: proc(scene: ^Scene, origin, direction: camera.Vec3, max_distance: f32) -> (int, f32) {
    closest_entity := -1
    closest_distance := max_distance
    
    for i := 0; i < len(scene.entities); i += 1 {
        entity := &scene.entities[i]
        
        if !entity.visible || !entity.collidable {
            continue
        }
        
        t := RayPlaneIntersection(origin, direction, entity.position)
        
        if t > 0 && t < closest_distance {
            dx := entity.position.x - origin.x
            dy := entity.position.y - origin.y  
            dz := entity.position.z - origin.z
            
            scale := entity.scale.x * 0.5
            
            if math.abs(dx - direction.x * t) < scale &&
               math.abs(dy - direction.y * t) < scale &&
               math.abs(dz - direction.z * t) < scale {
                closest_entity = i
                closest_distance = t
            }
        }
    }
    
    return closest_entity, closest_distance
}

RayPlaneIntersection :: proc(origin, direction: camera.Vec3, plane_point: camera.Vec3) -> f32 {
    denom := direction.x * direction.x + direction.y * direction.y + direction.z * direction.z
    if math.abs(denom) < 0.0001 {
        return -1
    }
    
    t := (plane_point.x - origin.x) * direction.x +
         (plane_point.y - origin.y) * direction.y +
         (plane_point.z - origin.z) * direction.z
    
    return t / denom
}

RaycastEntities :: proc(scene: ^Scene, ray: camera.Ray3D, max_distance: f32) -> (int, f32) {
    return Raycast(scene, ray.origin, ray.direction, max_distance)
}

AddDirectionalLight :: proc(scene: ^Scene, direction, color: camera.Vec3, intensity: f32) {
    scene.directional_light.direction = direction
    scene.directional_light.color = color
    scene.directional_light.intensity = intensity
    scene.directional_light.enabled = true
}

AddPointLight :: proc(scene: ^Scene, position, color: camera.Vec3, intensity, radius: f32) {
    light := PointLight{
        position = position,
        color = color,
        intensity = intensity,
        radius = radius,
        enabled = true,
    }
    scene.point_lights = append(scene.point_lights, light)
}

RemovePointLight :: proc(scene: ^Scene, index: int) {
    if index < 0 || index >= len(scene.point_lights) {
        return
    }
    scene.point_lights[index] = scene.point_lights[len(scene.point_lights) - 1]
    scene.point_lights = scene.point_lights[:len(scene.point_lights) - 1]
}

SetAmbientLight :: proc(scene: ^Scene, color: camera.Vec3) {
    scene.ambient_light = color
}

GetPlayerEntity :: proc(scene: ^Scene) -> ^Entity {
    for i := 0; i < len(scene.entities); i += 1 {
        if scene.entities[i].entity_type == EntityType.Player {
            return &scene.entities[i]
        }
    }
    return nil
}

CreatePlayer :: proc(scene: ^Scene, mesh: ^model_loader.LoadedMesh) -> int {
    entity := Entity{
        name = "Player",
        mesh = mesh,
        position = {0, 2, 5},
        rotation = {0, 0, 0},
        scale = {1, 2, 1},
        visible = true,
        collidable = true,
        mass = 70.0,
        entity_type = EntityType.Player,
    }
    scene.entities = append(scene.entities, entity)
    
    scene.camera.position = entity.position
    
    return len(scene.entities) - 1
}

CreateTree :: proc(scene: ^Scene, x, y, z: f32) -> int {
    return AddEntity(scene, fmt.sprint("Tree_", len(scene.entities)), nil)
}

CreateRock :: proc(scene: ^Scene, x, y, z: f32) -> int {
    return AddEntity(scene, fmt.sprint("Rock_", len(scene.entities)), nil)
}

CreateHouse :: proc(scene: ^Scene, x, y, z: f32) -> int {
    return AddEntity(scene, fmt.sprint("House_", len(scene.entities)), nil)
}

CreateNPC :: proc(scene: ^Scene, x, y, z: f32, name: string) -> int {
    return AddEntity(scene, name, nil)
}

LoadSceneFromWorld :: proc(scene: ^Scene, world_state: rawptr) {
    world := cast(^WorldData)world_state
    
    for i := 0; i < len(world.objects); i += 1 {
        obj := world.objects[i]
        switch obj.kind {
        case 0:
            CreateTree(scene, f32(obj.x), 0, f32(obj.y))
        case 1:
            CreateRock(scene, f32(obj.x), 0, f32(obj.y))
        case 2:
            CreateHouse(scene, f32(obj.x), 0, f32(obj.y))
        case 3:
            CreateNPC(scene, f32(obj.x), 0, f32(obj.y), "NPC")
        }
    }
}

WorldData :: struct {
    objects: []WorldObjectData,
}

WorldObjectData :: struct {
    x: int,
    y: int,
    kind: int,
}

cast :: proc($T: typeid)(rawptr) -> T {
    return T{}
}