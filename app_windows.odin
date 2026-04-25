package game_desktop

import "vendor:sdl2"
import "vendor:sdl2/ttf"
import "camera"

WindowMode :: enum {
    Desktop2D,
    Gaze3D,
}

WindowPane :: struct {
    x, y, width, height: int,
    title: string,
    r, g, b: u8,
    full_screen: bool,
    locked: bool,
    mode: WindowMode,
    position_3d: camera.Vec3,
    rotation_3d: camera.Vec2,
    distance: f32,
    visible: bool,
    closed: bool,
}

CreateWindowPane :: proc(title: string, x, y, width, height: int, r, g, b: u8) -> WindowPane {
    return WindowPane{
        x = x, y = y, width = width, height = height,
        title = title, r = r, g = g, b = b,
        full_screen = false, locked = false,
        mode = WindowMode.Desktop2D,
        position_3d = camera.Vec3{0, 0, 0},
        rotation_3d = camera.Vec2{0, 0},
        distance = 3.0,
        visible = true,
        closed = false,
    }
}

CreateWindowPane3D :: proc(title: string, pos: camera.Vec3, dist: f32) -> WindowPane {
    return WindowPane{
        x = 0, y = 0, width = 400, height = 300,
        title = title, r = 34, g = 56, b = 98,
        full_screen = false, locked = false,
        mode = WindowMode.Gaze3D,
        position_3d = pos,
        rotation_3d = camera.Vec2{0, 0},
        distance = dist,
        visible = true,
        closed = false,
    }
}

UpdateWindowFromGaze :: proc(win: ^WindowPane, cam: camera.Camera, placement: camera.WindowPlacement) {
    if win.mode == WindowMode.Gaze3D {
        win.position_3d = placement.position
        win.rotation_3d = cam.rotation
        win.distance = placement.distance
    }
}

ToggleFullScreen :: proc(win: ^WindowPane, screenW, screenH: int) {
    if win.full_screen {
        win.full_screen = false
        if win.mode == WindowMode.Gaze3D {
            win.mode = WindowMode.Desktop2D
        }
        if win.width > screenW - 120 {
            win.width = screenW - 120
        }
        if win.height > screenH - 120 {
            win.height = screenH - 120
        }
        win.x = 120
        win.y = 120
    } else {
        win.full_screen = true
        win.x = 0
        win.y = 0
        win.width = screenW
        win.height = screenH
        if win.mode == WindowMode.Gaze3D {
            win.mode = WindowMode.Desktop2D
        }
    }
}

ConvertTo3D :: proc(win: ^WindowPane, cam: camera.Camera, distance: f32) {
    placement := camera.CalcWindowPlacement(cam, distance)
    win.mode = WindowMode.Gaze3D
    win.position_3d = placement.position
    win.rotation_3d = cam.rotation
    win.distance = distance
    win.full_screen = false
}

ConvertTo2D :: proc(win: ^WindowPane, screenW, screenH: int, cam: camera.Camera) {
    win.mode = WindowMode.Desktop2D
    sx, sy, visible := camera.GetWindowScreenPosition(cam, win.position_3d, screenW, screenH)
    if visible {
        win.x = int(sx) - win.width / 2
        win.y = int(sy) - win.height / 2
    } else {
        win.x = 120
        win.y = 120
    }
}

GetWindowScreenPos :: proc(win: WindowPane, cam: camera.Camera, screenW, screenH: int) -> (f32, f32, bool) {
    return camera.GetWindowScreenPosition(cam, win.position_3d, screenW, screenH)
}

WindowTitleHit :: proc(win: WindowPane, mx, my: int) -> bool {
    return mx >= win.x && mx < win.x + win.width && my >= win.y && my < win.y + 36
}

LockHover :: proc(win: WindowPane, mx, my: int) -> bool {
    return mx >= win.x + win.width - 32 && mx < win.x + win.width - 8 && my >= win.y + 8 && my < win.y + 28
}

HoverFullScreen :: proc(win: WindowPane, mx, my: int) -> bool {
    return mx >= win.x + win.width - 64 && mx < win.x + win.width - 40 && my >= win.y + 8 && my < win.y + 28
}

DragStart :: proc(win: WindowPane, mx, my: int) -> bool {
    return mx >= win.x && mx < win.x + win.width - 70 && my >= win.y && my < win.y + 36
}

ConvertToGaze3D :: proc(win: ^WindowPane, cam: camera.Camera, placement: camera.WindowPlacement) {
    if win.locked {
        return
    }
    win.mode = WindowMode.Gaze3D
    win.position_3d = placement.position
    win.rotation_3d = cam.rotation
    win.distance = placement.distance
}

DrawWindowPane3D :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, win: WindowPane, cam: camera.Camera, screenW, screenH: int, active: bool) {
    sx, sy, visible := camera.GetWindowScreenPosition(cam, win.position_3d, screenW, screenH)
    
    if !visible {
        return
    }
    
    sx := int(sx)
    sy := int(sy)
    
    bgR, bgG, bgB := win.r, win.g, win.b
    titleR, titleG, titleB := u8(24), u8(32), u8(56)
    if active {
        titleR, titleG, titleB = 70, 140, 230
    }
    
    depth_alpha := u8(180)
    if win.distance > 8.0 {
        depth_alpha = 120
    } else if win.distance < 2.0 {
        depth_alpha = 230
    }
    
    DrawRect(renderer, sx, sy, win.width, win.height, bgR, bgG, bgB, depth_alpha)
    DrawRect(renderer, sx + 6, sy + 6, win.width - 12, win.height - 12, 16, 24, 38, depth_alpha)
    DrawRect(renderer, sx, sy, win.width, 36, titleR, titleG, titleB, 255)
    DrawTextOrPlaceholder(renderer, font, win.title, sx + 12, sy + 8)
    
    dist_label := "3D"
    DrawTextOrPlaceholder(renderer, font, dist_label, sx + win.width - 44, sy + 8)
    
    DrawRect(renderer, sx + 16, sy + 52, win.width - 32, win.height - 68, 12, 18, 28, depth_alpha)
    DrawTextOrPlaceholder(renderer, font, "Gaze Mode", sx + 32, sy + 70)
}

DrawWindowPane :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, win: WindowPane, cam: camera.Camera, screenW, screenH: int, active: bool) {
    if win.mode == WindowMode.Gaze3D {
        DrawWindowPane3D(renderer, font, win, cam, screenW, screenH, active)
    } else {
        DrawWindowPaneDesktop(renderer, font, win, active)
    }
}

ToggleLock :: proc(win: ^WindowPane) {
    win.locked = !win.locked
}

AnyFullScreenOpen :: proc(windows: []WindowPane) -> bool {
    for i := 0; i < len(windows); i += 1 {
        win := windows[i]
        if win.full_screen {
            return true
        }
    }
    return false
}

DrawRect :: proc(renderer: ^sdl.Renderer, x, y, w, h: int, r, g, b, a: u8) {
    rect := sdl.Rect{x, y, w, h}
    sdl.set_render_draw_color(renderer, r, g, b, a)
    sdl.render_fill_rect(renderer, &rect)
}

DrawWindowPaneDesktop :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, win: WindowPane, active: bool) {
    bgR, bgG, bgB := win.r, win.g, win.b
    titleR, titleG, titleB := u8(24), u8(32), u8(56)
    if active {
        titleR, titleG, titleB = 70, 140, 230
    }
    if win.full_screen {
        DrawRect(renderer, win.x, win.y, win.width, win.height, bgR, bgG, bgB, 255)
    } else {
        DrawRect(renderer, win.x, win.y, win.width, win.height, bgR, bgG, bgB, 220)
        DrawRect(renderer, win.x + 6, win.y + 6, win.width - 12, win.height - 12, 16, 24, 38, 180)
    }
    DrawRect(renderer, win.x, win.y, win.width, 36, titleR, titleG, titleB, 255)
    DrawTextOrPlaceholder(renderer, font, win.title, win.x + 12, win.y + 8)
    lockLabel := "L"
    if win.locked {
        lockLabel = "L"
    }
    DrawTextOrPlaceholder(renderer, font, lockLabel, win.x + win.width - 28, win.y + 8)
    modeLabel := "2D"
    DrawTextOrPlaceholder(renderer, font, modeLabel, win.x + win.width - 56, win.y + 8)
    if !win.full_screen {
        DrawRect(renderer, win.x + 16, win.y + 52, win.width - 32, win.height - 68, 12, 18, 28, 220)
        DrawTextOrPlaceholder(renderer, font, "Window content area", win.x + 32, win.y + 70)
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

DrawWindowPane :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, win: WindowPane, cam: camera.Camera, screenW, screenH: int, active: bool) {
    if win.mode == WindowMode.Gaze3D {
        DrawWindowPane3D(renderer, font, win, cam, screenW, screenH, active)
    } else {
        DrawWindowPaneDesktop(renderer, font, win, active)
    }
}
