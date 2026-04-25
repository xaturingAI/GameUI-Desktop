package game_desktop

import "vendor:sdl2"
import "vendor:sdl2/ttf"

AppLauncher :: struct {
    x, y, width, height: int,
    open: bool,
    apps: []string,
    selected: int,
}

ToggleLauncher :: proc(launcher: ^AppLauncher) {
    launcher.open = !launcher.open
}

LauncherHit :: proc(launcher: AppLauncher, mx, my: int) -> bool {
    return mx >= launcher.x && mx < launcher.x + launcher.width && my >= launcher.y && my < launcher.y + launcher.height
}

AppIconHit :: proc(launcher: AppLauncher, mx, my: int) -> int {
    iconSize := 48
    cellX := launcher.x + 16
    cellY := launcher.y + 48
    for i := 0; i < len(launcher.apps); i += 1 {
        ix := cellX + (i % 4) * (iconSize + 12)
        iy := cellY + (i / 4) * (iconSize + 12)
        if mx >= ix && mx < ix + iconSize && my >= iy && my < iy + iconSize {
            return i
        }
    }
    return -1
}

DrawLauncher :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, launcher: AppLauncher) {
    bgR, bgG, bgB := u8(18), u8(26), u8(46)
    DrawRect(renderer, launcher.x, launcher.y, launcher.width, launcher.height, bgR, bgG, bgB, 225)
    DrawRect(renderer, launcher.x, launcher.y, launcher.width, 36, 32, 52, 96, 255)
    DrawTextOrPlaceholder(renderer, font, "App Launcher", launcher.x + 12, launcher.y + 8)
    if launcher.open {
        iconSize := 48
        for i := 0; i < len(launcher.apps); i += 1 {
            app := launcher.apps[i]
            ix := launcher.x + 16 + (i % 4) * (iconSize + 12)
            iy := launcher.y + 48 + (i / 4) * (iconSize + 12)
            DrawRect(renderer, ix, iy, iconSize, iconSize, 48, 68, 120, 255)
            DrawTextOrPlaceholder(renderer, font, app, ix + 4, iy + 12)
        }
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
        DrawRect(renderer, x, y, int(len(text)) * 9 + 20, 28, 80, 80, 80, 200)
    }
}
