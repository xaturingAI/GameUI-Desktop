package game_desktop

import "core:fmt"
import "core:os"
import "core:strings"
import "vendor:sdl2"
import "vendor:sdl2/ttf"

ModelAsset :: struct {
    path: string,
    name: string,
    extension: string,
    x, y: int,
    locked: bool,
}

ModelManager :: struct {
    models: []ModelAsset,
    supported_extensions: []string,
}

InitModelManager :: proc() -> ModelManager {
    return ModelManager{
        models = []ModelAsset{},
        supported_extensions = []string{".obj", ".fbx", ".gltf", ".glb", ".dae", ".stl", ".ply", ".3ds", ".blend"},
    }
}

GetExtension :: proc(path: string) -> string {
    lower := strings.to_lower(path)
    dot := -1
    for i := len(lower)-1; i >= 0; i -= 1 {
        if lower[i] == '.' {
            dot = i
            break
        }
    }
    if dot >= 0 {
        return lower[dot:]
    }
    return ""
}

SupportsExtension :: proc(manager: ModelManager, extension: string) -> bool {
    if extension == "" {
        return false
    }
    for i := 0; i < len(manager.supported_extensions); i += 1 {
        ext := manager.supported_extensions[i]
        if ext == extension {
            return true
        }
    }
    return false
}

GetName :: proc(path: string) -> string {
    nameStart := 0
    for i := len(path)-1; i >= 0; i -= 1 {
        if path[i] == '/' || path[i] == '\\' {
            nameStart = i + 1
            break
        }
    }
    nameEnd := len(path)
    for i := len(path)-1; i >= nameStart; i -= 1 {
        if path[i] == '.' {
            nameEnd = i
            break
        }
    }
    return path[nameStart:nameEnd]
}

AddModel :: proc(manager: ^ModelManager, path: string) -> bool {
    if path == "" {
        return false
    }
    extension := GetExtension(path)
    if !SupportsExtension(*manager, extension) {
        return false
    }

    name := GetName(path)
    x := 100 + len(manager.models) * 100
    y := 360
    if x > 900 {
        x = 100 + (len(manager.models) % 6) * 100
        y += 100
    }

    model := ModelAsset{path = path, name = name, extension = extension, x = x, y = y, locked = false}
    manager.models = append(manager.models, model)
    return true
}

LoadModelsFromEnv :: proc(manager: ^ModelManager) {
    pathList := os.getenv("GAMEUI_MODEL_PATHS")
    if pathList == "" {
        singlePath := os.getenv("GAMEUI_MODEL_PATH")
        if singlePath != "" {
            pathList = singlePath
        }
    }
    if pathList == "" {
        return
    }

    candidates := strings.split(pathList, ",")
    for i := 0; i < len(candidates); i += 1 {
        candidate := strings.trim(candidates[i])
        if candidate != "" {
            if !manager.AddModel(candidate) {
                fmt.println("Skipped unsupported model:", candidate)
            }
        }
    }
}

ToggleModelLock :: proc(manager: ^ModelManager, index: int) {
    if index < 0 || index >= len(manager.models) {
        return
    }
    model := manager.models[index]
    model.locked = !model.locked
    manager.models[index] = model
}

ModelHit :: proc(manager: ModelManager, mx, my: int) -> int {
    for i := 0; i < len(manager.models); i += 1 {
        model := manager.models[i]
        if mx >= model.x && mx < model.x + 80 && my >= model.y && my < model.y + 80 {
            return i
        }
    }
    return -1
}

DrawModels :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, manager: ModelManager) {
    for i := 0; i < len(manager.models); i += 1 {
        model := manager.models[i]
        DrawRect(renderer, model.x, model.y, 80, 80, 54, 74, 104, 230)
        DrawRect(renderer, model.x + 4, model.y + 4, 72, 72, 28, 36, 54, 210)
        DrawTextOrPlaceholder(renderer, font, model.name, model.x + 6, model.y + 10)
        DrawTextOrPlaceholder(renderer, font, model.extension, model.x + 6, model.y + 34)
        if model.locked {
            DrawTextOrPlaceholder(renderer, font, "L", model.x + 54, model.y + 10)
        }
        DrawTextOrPlaceholder(renderer, font, fmt.sprint("#", i+1), model.x + 6, model.y + 58)
    }
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
        rect := sdl.Rect{x, y, int(len(text)) * 9 + 20, 28}
        sdl.set_render_draw_color(renderer, 80, 80, 80, 200)
        sdl.render_fill_rect(renderer, &rect)
    }
}
