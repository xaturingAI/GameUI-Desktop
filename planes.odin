package game_desktop

import "core:fmt"
import "vendor:sdl2"
import "vendor:sdl2/ttf"

Plane :: struct {
    x, y, width, height: int,
    title: string,
    locked: bool,
    r, g, b: u8,
    pinned_apps: []string,
}

PlaneHit :: proc(p: Plane, mx, my: int) -> bool {
    return mx >= p.x && mx < p.x + p.width && my >= p.y && my < p.y + p.height
}

PlaneTitleHit :: proc(p: Plane, mx, my: int) -> bool {
    return mx >= p.x && mx < p.x + p.width && my >= p.y && my < p.y + 36
}

PlaneLockHit :: proc(p: Plane, mx, my: int) -> bool {
    return mx >= p.x + p.width - 28 && mx < p.x + p.width - 8 && my >= p.y + 8 && my < p.y + 28
}

DrawPinnedApps :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, p: Plane) {
    iconSize := 40
    iconX := p.x + 16
    iconY := p.y + 44
    for i := 0; i < len(p.pinned_apps); i += 1 {
        app := p.pinned_apps[i]
        DrawRect(renderer, iconX + i * (iconSize + 8), iconY, iconSize, iconSize, 48, 68, 120, 255)
        DrawTextOrPlaceholder(renderer, font, app, iconX + i * (iconSize + 8) + 4, iconY + 12)
    }
}

DrawPlane :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, p: Plane, active: bool) {
    titleR, titleG, titleB := u8(24), u8(32), u8(56)
    if active {
        titleR, titleG, titleB = 88, 164, 236
    }

    DrawRect(renderer, p.x, p.y, p.width, p.height, p.r, p.g, p.b, 210)
    DrawRect(renderer, p.x, p.y, p.width, 36, titleR, titleG, titleB, 255)
    DrawTextOrPlaceholder(renderer, font, p.title, p.x + 12, p.y + 8)
    lockText := "L"
    if p.locked {
        lockText = "🔒"
    }
    DrawTextOrPlaceholder(renderer, font, lockText, p.x + p.width - 28, p.y + 8)
    DrawRect(renderer, p.x + 12, p.y + 52, p.width - 24, p.height - 64, 16, 24, 36, 210)
    DrawPinnedApps(renderer, font, p)
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

FormatPlaneList :: proc(planes: []Plane) -> string {
    titles := []string{}
    for i := 0; i < len(planes); i += 1 {
        titles = append(titles, planes[i].title)
    }
    return fmt.join(titles, ", ")
}
