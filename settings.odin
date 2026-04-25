package game_desktop

import "core:fmt"
import "vendor:sdl2"
import "vendor:sdl2/ttf"

ActionToggleLauncher :: 0
ActionToggleSettings :: 1
ActionCycleWindows :: 2
ActionCloseWindow :: 3
ActionToggleLock :: 4

SettingsState :: struct {
    open: bool,
    theme: int,
    themes: []string,
    background_mode: int,
    background_modes: []string,
    world_seed: u64,
    seed_locked: bool,
    use_location_time: bool,
    day_length: int,
    night_length: int,
    model_lock: bool,
    import_models_request: bool,
    import_sky_request: bool,
    show_clock: bool,
    lock_planes: bool,
    toggle_launcher_key: int,
    toggle_settings_key: int,
    cycle_windows_key: int,
    close_app_key: int,
    lock_window_key: int,
    awaiting_rebind: bool,
    rebind_action: int,
}

InitSettings :: proc() -> SettingsState {
    return SettingsState{
        open = false,
        theme = 0,
        themes = []string{"MMO Classic", "Dark", "Neon"},
        background_mode = 0,
        background_modes = []string{"Normal Wallpaper", "Game World", "MMO Desktop"},
        world_seed = 0,
        seed_locked = false,
        use_location_time = false,
        day_length = 30,
        night_length = 18,
        model_lock = false,
        import_models_request = false,
        import_sky_request = false,
        show_clock = true,
        lock_planes = false,
        toggle_launcher_key = sdl.K_a,
        toggle_settings_key = sdl.K_s,
        cycle_windows_key = sdl.K_TAB,
        close_app_key = sdl.K_c,
        lock_window_key = sdl.K_l,
        awaiting_rebind = false,
        rebind_action = ActionToggleLauncher,
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

ToggleSettings :: proc(s: ^SettingsState) {
    s.open = !s.open
    if !s.open {
        s.awaiting_rebind = false
    }
}

SettingsHit :: proc(mx, my: int) -> bool {
    return mx >= 32 && mx < 150 && my >= 12 && my < 44
}

OptionHit :: proc(y, mx, my: int) -> bool {
    return mx >= 120 && mx < 420 && my >= y && my < y + 28
}

KeyName :: proc(keycode: int) -> string {
    name := sdl.get_key_name(keycode)
    if name == "" {
        return "Unknown"
    }
    return name
}

ActionName :: proc(action: int) -> string {
    name := "Unknown Action"
    switch action {
    case ActionToggleLauncher:
        name = "Open Launcher"
    case ActionToggleSettings:
        name = "Toggle Settings"
    case ActionCycleWindows:
        name = "Cycle Windows"
    case ActionCloseWindow:
        name = "Close Window"
    case ActionToggleLock:
        name = "Lock/Unlock Window"
    }
    return name
}

GetKeyBinding :: proc(s: SettingsState, action: int) -> int {
    key := 0
    switch action {
    case ActionToggleLauncher:
        key = s.toggle_launcher_key
    case ActionToggleSettings:
        key = s.toggle_settings_key
    case ActionCycleWindows:
        key = s.cycle_windows_key
    case ActionCloseWindow:
        key = s.close_app_key
    case ActionToggleLock:
        key = s.lock_window_key
    }
    return key
}

SetKeyBinding :: proc(s: ^SettingsState, action: int, keycode: int) {
    switch action {
    case ActionToggleLauncher:
        s.toggle_launcher_key = keycode
    case ActionToggleSettings:
        s.toggle_settings_key = keycode
    case ActionCycleWindows:
        s.cycle_windows_key = keycode
    case ActionCloseWindow:
        s.close_app_key = keycode
    case ActionToggleLock:
        s.lock_window_key = keycode
    }
}

HandleSettingsClick :: proc(s: ^SettingsState, mx, my: int) {
    if !s.open {
        return
    }

    themeStart := 120
    for i := 0; i < len(s.themes); i += 1 {
        if OptionHit(themeStart + i*34, mx, my) {
            s.theme = i
            return
        }
    }

    modeStart := 220
    for i := 0; i < len(s.background_modes); i += 1 {
        if OptionHit(modeStart + i*34, mx, my) {
            s.background_mode = i
            return
        }
    }

    if OptionHit(320, mx, my) {
        s.show_clock = !s.show_clock
        return
    }
    if OptionHit(356, mx, my) {
        s.lock_planes = !s.lock_planes
        return
    }
    if OptionHit(392, mx, my) {
        s.seed_locked = !s.seed_locked
        return
    }
    if OptionHit(428, mx, my) {
        s.use_location_time = !s.use_location_time
        return
    }
    if OptionHit(464, mx, my) {
        s.day_length += 5
        if s.day_length > 120 {
            s.day_length = 10
        }
        return
    }
    if OptionHit(500, mx, my) {
        s.night_length += 5
        if s.night_length > 120 {
            s.night_length = 10
        }
        return
    }

    bindingStart := 544
    for action := 0; action < 5; action += 1 {
        if OptionHit(bindingStart + action*34, mx, my) {
            s.awaiting_rebind = true
            s.rebind_action = action
            return
        }
    }

    if OptionHit(790, mx, my) {
        s.import_sky_request = true
        return
    }
}

DrawSettings :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, s: SettingsState) {
    if !s.open {
        return
    }

    x := 120
    y := 72
    width := 420
    height := 860
    sdl.set_render_draw_color(renderer, 18, 28, 48, 220)
    rect := sdl.Rect{x, y, width, height}
    sdl.render_fill_rect(renderer, &rect)

    sdl.set_render_draw_color(renderer, 36, 54, 92, 255)
    sdl.render_fill_rect(renderer, &sdl.Rect{x, y, width, 40})
    DrawTextOrPlaceholder(renderer, font, "Settings Manager", x + 16, y + 10)

    DrawTextOrPlaceholder(renderer, font, "Theme", x + 16, y + 60)
    for i := 0; i < len(s.themes); i += 1 {
        theme := s.themes[i]
        label := theme
        if s.theme == i {
            label = theme + " (active)"
        }
        DrawTextOrPlaceholder(renderer, font, label, x + 24, y + 102 + i*34)
    }

    DrawTextOrPlaceholder(renderer, font, "Background Mode", x + 16, y + 220)
    for i := 0; i < len(s.background_modes); i += 1 {
        mode := s.background_modes[i]
        label := mode
        if s.background_mode == i {
            label = mode + " (active)"
        }
        DrawTextOrPlaceholder(renderer, font, label, x + 24, y + 262 + i*34)
    }

    DrawTextOrPlaceholder(renderer, font, "Show Clock", x + 16, y + 320)
    clockLabel := "Disabled"
    if s.show_clock {
        clockLabel = "Enabled"
    }
    DrawTextOrPlaceholder(renderer, font, clockLabel, x + 260, y + 320)

    DrawTextOrPlaceholder(renderer, font, "Lock Planes", x + 16, y + 356)
    planesLabel := "Unlocked"
    if s.lock_planes {
        planesLabel = "Locked"
    }
    DrawTextOrPlaceholder(renderer, font, planesLabel, x + 260, y + 356)

    DrawTextOrPlaceholder(renderer, font, "World Seed", x + 16, y + 392)
    DrawTextOrPlaceholder(renderer, font, fmt.sprint(s.world_seed), x + 260, y + 392)

    DrawTextOrPlaceholder(renderer, font, "Seed Locked", x + 16, y + 428)
    seedLabel := "Unlocked"
    if s.seed_locked {
        seedLabel = "Locked"
    }
    DrawTextOrPlaceholder(renderer, font, seedLabel, x + 260, y + 428)

    DrawTextOrPlaceholder(renderer, font, "Use Location Time", x + 16, y + 464)
    locLabel := "Disabled"
    if s.use_location_time {
        locLabel = "Enabled"
    }
    DrawTextOrPlaceholder(renderer, font, locLabel, x + 260, y + 464)

    DrawTextOrPlaceholder(renderer, font, "Day Length (sec)", x + 16, y + 500)
    DrawTextOrPlaceholder(renderer, font, fmt.sprint(s.day_length), x + 260, y + 500)

    DrawTextOrPlaceholder(renderer, font, "Night Length (sec)", x + 16, y + 536)
    DrawTextOrPlaceholder(renderer, font, fmt.sprint(s.night_length), x + 260, y + 536)

    DrawTextOrPlaceholder(renderer, font, "Key Bindings", x + 16, y + 572)
    for action := 0; action < 5; action += 1 {
        label := ActionName(action)
        if s.awaiting_rebind && s.rebind_action == action {
            DrawTextOrPlaceholder(renderer, font, label + " → Press new key...", x + 24, y + 614 + action*34)
        } else {
            DrawTextOrPlaceholder(renderer, font, label, x + 24, y + 614 + action*34)
            DrawTextOrPlaceholder(renderer, font, KeyName(GetKeyBinding(s, action)), x + 260, y + 614 + action*34)
        }
    }

    DrawTextOrPlaceholder(renderer, font, "Import Sky Modules", x + 16, y + 790)
    DrawTextOrPlaceholder(renderer, font, "Use GAMEUI_SUN_MODULE/MOON_MODULE/DAY_SKY/NIGHT_SKY", x + 24, y + 822)
}
