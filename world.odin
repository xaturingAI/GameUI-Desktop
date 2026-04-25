package game_desktop

import "core:fmt"
import "core:math"
import "core:os"
import "vendor:sdl2"
import "vendor:sdl2/ttf"

BackgroundModeWallpaper :: 0
BackgroundModeGameWorld :: 1
BackgroundModeMMO :: 2
TerrainGrass :: 0
TerrainSand :: 1
TerrainWater :: 2
TerrainStone :: 3
ObjectTree :: 0
ObjectRock :: 1
ObjectHouse :: 2
ObjectNPC :: 3

WorldTile :: struct {
    terrain: int,
}

WorldObject :: struct {
    x, y: int,
    kind: int,
}

WorldState :: struct {
    seed: u64,
    width, height: int,
    tiles: []WorldTile,
    objects: []WorldObject,
    time: f32,
    ambient: f32,
    name: string,
}

InitWorldState :: proc(seed: u64, screenW, screenH: int) -> WorldState {
    width := screenW / 32
    height := screenH / 32
    if width < 16 {
        width = 16
    }
    if height < 12 {
        height = 12
    }
    state := WorldState{seed = seed, width = width, height = height, time = 0.0, ambient = 1.0, name = GenerateWorldName(seed)}
    GenerateWorld(&state)
    return state
}

RandomSeed :: proc() -> u64 {
    now := os.time()
    return u64(now)*6364136223846793005 + 1442695040888963407
}

UpdateWorldSeed :: proc(state: ^WorldState, seed: u64) {
    if state.seed != seed {
        state.seed = seed
        state.name = GenerateWorldName(seed)
        GenerateWorld(state)
    }
}

GenerateWorld :: proc(state: ^WorldState) {
    count := state.width * state.height
    if len(state.tiles) != count {
        state.tiles = make([]WorldTile, count)
    }
    for y := 0; y < state.height; y += 1 {
        for x := 0; x < state.width; x += 1 {
            state.tiles[y*state.width + x].terrain = GenerateTerrain(state.seed, x, y)
        }
    }
    GenerateWorldObjects(state)
}

HashPoint :: proc(seed: u64, x, y: int) -> u64 {
    h := seed
    h ^= u64(x) * 0x9e3779b97f4a7c15
    h ^= u64(y) * 0xc6a4a7935bd1e995
    h = (h ^ (h >> 30)) * 0xbf58476d1ce4e5b9
    h = (h ^ (h >> 27)) * 0x94d049bb133111eb
    return h ^ (h >> 31)
}

Noise2D :: proc(seed: u64, x, y: int, scale: f32) -> f32 {
    offX := int(f32(x) * scale)
    offY := int(f32(y) * scale)
    value := HashPoint(seed, offX, offY) & 0xffffffff
    return f32(value) / 4294967295.0
}

GenerateTerrain :: proc(seed: u64, x, y: int) -> int {
    base := Noise2D(seed, x, y, 0.08) * 0.5
    base += Noise2D(seed + 1, x, y, 0.18) * 0.28
    base += Noise2D(seed + 2, x, y, 0.42) * 0.22
    height := base
    if height < 0.28 {
        return TerrainWater
    }
    if height < 0.35 {
        return TerrainSand
    }
    if height > 0.82 {
        return TerrainStone
    }
    return TerrainGrass
}

GenerateWorldObjects :: proc(state: ^WorldState) {
    state.objects = make([]WorldObject, 0)
    for y := 0; y < state.height; y += 1 {
        for x := 0; x < state.width; x += 1 {
            terrain := state.tiles[y*state.width + x].terrain
            noise := Noise2D(state.seed + 7, x, y, 0.22)
            if terrain == TerrainWater {
                continue
            }
            if terrain == TerrainSand && noise > 0.86 {
                state.objects = append(state.objects, WorldObject{x = x, y = y, kind = ObjectRock})
            }
            if terrain == TerrainGrass {
                if noise > 0.76 {
                    state.objects = append(state.objects, WorldObject{x = x, y = y, kind = ObjectTree})
                } else if noise < 0.07 {
                    state.objects = append(state.objects, WorldObject{x = x, y = y, kind = ObjectNPC})
                }
            }
            if terrain == TerrainStone && noise > 0.88 {
                state.objects = append(state.objects, WorldObject{x = x, y = y, kind = ObjectHouse})
            }
        }
    }
}

GenerateWorldName :: proc(seed: u64) -> string {
    names := []string{"Astra Vale", "Nebula Reach", "Ember Crest", "Mystwood", "Echo Hollow", "Luna Fields"}
    index := int(seed % u64(len(names)))
    return names[index]
}

UpdateLighting :: proc(state: ^WorldState, dt: f32) {
    state.time += dt * 0.08
    base := 0.7 + 0.3 * math.sin(state.time)
    if base < 0.35 {
        base = 0.35
    }
    state.ambient = base
}

GetTerrainColor :: proc(terrain: int) -> (u8, u8, u8) {
    r, g, b: u8
    switch terrain {
    case TerrainWater:
        r = 28
        g = 92
        b = 150
    case TerrainSand:
        r = 180
        g = 160
        b = 120
    case TerrainStone:
        r = 100
        g = 104
        b = 112
    default:
        r = 60
        g = 132
        b = 68
    }
    return r, g, b
}

ApplyAmbient :: proc(value: u8, ambient: f32) -> u8 {
    lit := f32(value) * ambient
    if lit > 255.0 {
        lit = 255.0
    }
    if lit < 0.0 {
        lit = 0.0
    }
    return u8(lit)
}

DrawRect :: proc(renderer: ^sdl.Renderer, x, y, w, h: int, r, g, b, a: u8) {
    rect := sdl.Rect{x, y, w, h}
    sdl.set_render_draw_color(renderer, r, g, b, a)
    sdl.render_fill_rect(renderer, &rect)
}

DrawTextOrPlaceholder :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, text: string, x, y: int) {
    if font != nil {
        color := sdl.Color{255, 255, 255, 255}
        surface := sdl_ttf.render_text_blended(font, text, color)
        if surface == nil {
            return
        }
        texture := sdl.create_texture_from_surface(renderer, surface)
        if texture == nil {
            sdl.free_surface(surface)
            return
        }
        rect := sdl.Rect{x, y, surface.w, surface.h}
        sdl.render_copy(renderer, texture, nil, &rect)
        sdl.destroy_texture(texture)
        sdl.free_surface(surface)
    } else {
        placeholder := sdl.Rect{x, y, int(len(text)) * 9 + 20, 28}
        sdl.set_render_draw_color(renderer, 80, 80, 80, 200)
        sdl.render_fill_rect(renderer, &placeholder)
    }
}

DrawWallpaperBackground :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, screenW, screenH: int) {
    for i := 0; i < screenH; i += 24 {
        shade := u8(22 + (i * 120 / screenH))
        DrawRect(renderer, 0, i, screenW, 24, shade, shade, u8(shade + 16), 255)
    }
    DrawRect(renderer, 100, 90, screenW - 200, screenH - 220, 24, 32, 56, 220)
    DrawTextOrPlaceholder(renderer, font, "Wallpaper Desktop", 120, 108)
    DrawTextOrPlaceholder(renderer, font, "Normal mode for low GPU desktop use.", 120, 144)
    DrawRect(renderer, 120, 220, 88, 88, 38, 58, 112, 255)
    DrawTextOrPlaceholder(renderer, font, "Web", 128, 254)
    DrawRect(renderer, 240, 220, 88, 88, 38, 58, 112, 255)
    DrawTextOrPlaceholder(renderer, font, "Files", 248, 254)
    DrawRect(renderer, 360, 220, 88, 88, 38, 58, 112, 255)
    DrawTextOrPlaceholder(renderer, font, "Chat", 368, 254)
}

DrawWorldObject :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, obj: WorldObject, tileW, tileH: int, ambient: f32) {
    ox := obj.x*tileW
    oy := obj.y*tileH
    switch obj.kind {
    case ObjectTree:
        DrawRect(renderer, ox + tileW/2 - 4, oy + tileH - 18, 8, 18, 92, 55, 30, 255)
        DrawRect(renderer, ox + tileW/2 - 14, oy + tileH - 36, 28, 24, ApplyAmbient(26, ambient), ApplyAmbient(132, ambient), ApplyAmbient(56, ambient), 255)
    case ObjectRock:
        DrawRect(renderer, ox + tileW/2 - 8, oy + tileH - 12, 16, 12, ApplyAmbient(120, ambient), ApplyAmbient(110, ambient), ApplyAmbient(95, ambient), 255)
    case ObjectHouse:
        DrawRect(renderer, ox + tileW/2 - 12, oy + tileH - 20, 24, 20, ApplyAmbient(180, ambient), ApplyAmbient(120, ambient), ApplyAmbient(90, ambient), 255)
        DrawRect(renderer, ox + tileW/2 - 16, oy + tileH - 34, 32, 16, ApplyAmbient(120, ambient), ApplyAmbient(44, ambient), ApplyAmbient(32, ambient), 255)
    case ObjectNPC:
        DrawRect(renderer, ox + tileW/2 - 6, oy + tileH - 16, 12, 16, ApplyAmbient(200, ambient), ApplyAmbient(80, ambient), ApplyAmbient(80, ambient), 255)
    }
}

DrawGameWorldBackground :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, screenW, screenH: int, state: WorldState, manager: models.ModelManager, lightingState: lighting.LightingState) {
    lighting.DrawSky(renderer, font, screenW, screenH, lightingState)
    tileW := screenW / state.width
    tileH := screenH / state.height
    for y := 0; y < state.height; y += 1 {
        for x := 0; x < state.width; x += 1 {
            tile := state.tiles[y*state.width + x]
            r, g, b := GetTerrainColor(tile.terrain)
            DrawRect(renderer, x*tileW, y*tileH, tileW+1, tileH+1, ApplyAmbient(r, state.ambient), ApplyAmbient(g, state.ambient), ApplyAmbient(b, state.ambient), 255)
        }
    }
    for i := 0; i < len(state.objects); i += 1 {
        obj := state.objects[i]
        if obj.x >= 0 && obj.x < state.width && obj.y >= 0 && obj.y < state.height {
            DrawWorldObject(renderer, font, obj, tileW, tileH, state.ambient)
        }
    }
    models.DrawModels(renderer, font, manager)
    DrawRect(renderer, 16, 16, 260, 82, 20, 26, 40, 200)
    DrawTextOrPlaceholder(renderer, font, fmt.sprint("World: ", state.name), 24, 24)
    DrawTextOrPlaceholder(renderer, font, fmt.sprint("Seed: ", state.seed), 24, 46)
    DrawTextOrPlaceholder(renderer, font, fmt.sprint("Light: ", int(state.ambient*100.0), "%"), 24, 68)
}

DrawLightingOverlay :: proc(renderer: ^sdl.Renderer, state: WorldState, screenW, screenH: int) {
    alpha := u8(120 - int(state.ambient*40.0))
    for layer := 0; layer < 4; layer += 1 {
        size := 260 + layer*140
        x := (screenW - size) / 2
        y := (screenH - size) / 2
        DrawRect(renderer, x, y, size, size, 24, 32, 56, alpha)
    }
}

DrawMMOOverlay :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font) {
    DrawRect(renderer, 100, 12, 1080, 76, 28, 40, 68, 220)
    DrawRect(renderer, 116, 26, 320, 24, 200, 32, 32, 255)
    DrawRect(renderer, 116, 56, 320, 24, 32, 96, 200, 255)
    DrawRect(renderer, 460, 26, 300, 24, 230, 200, 40, 255)
    DrawRect(renderer, 1060, 12, 184, 184, 18, 22, 36, 230)
    DrawTextOrPlaceholder(renderer, font, "MMO HUD", 120, 20)
    DrawTextOrPlaceholder(renderer, font, "Health", 120, 50)
    DrawTextOrPlaceholder(renderer, font, "Mana", 120, 80)
    DrawTextOrPlaceholder(renderer, font, "XP", 460, 50)
}

DrawDesktopBackground :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, mode: int, fullScreen: bool, screenW, screenH: int, state: WorldState, manager: models.ModelManager, lightingState: lighting.LightingState) {
    if fullScreen {
        DrawWallpaperBackground(renderer, font, screenW, screenH)
        return
    }
    switch mode {
    case BackgroundModeGameWorld:
        DrawGameWorldBackground(renderer, font, screenW, screenH, state, manager, lightingState)
    case BackgroundModeMMO:
        DrawMMOOverlay(renderer, font)
    default:
        DrawWallpaperBackground(renderer, font, screenW, screenH)
    }
}
