package game_desktop

import "core:fmt"
import "core:math"
import "core:os"
import "vendor:sdl2"
import "vendor:sdl2/ttf"

LightingState :: struct {
    use_location_time: bool
    day_length: f32
    night_length: f32
    current_cycle: f32
    time_of_day: f32
    ambient: f32
    sun_asset: string
    moon_asset: string
    day_sky_asset: string
    night_sky_asset: string
}

InitLightingState :: proc() -> LightingState {
    return LightingState{
        use_location_time = false,
        day_length = 30.0,
        night_length = 18.0,
        current_cycle = 0.0,
        time_of_day = 0.5,
        ambient = 1.0,
        sun_asset = "",
        moon_asset = "",
        day_sky_asset = "",
        night_sky_asset = "",
    }
}

LoadSkyModulesFromEnv :: proc(state: ^LightingState) {
    sunPath := os.getenv("GAMEUI_SUN_MODULE")
    moonPath := os.getenv("GAMEUI_MOON_MODULE")
    daySkyPath := os.getenv("GAMEUI_DAY_SKY")
    nightSkyPath := os.getenv("GAMEUI_NIGHT_SKY")

    if sunPath != "" {
        state.sun_asset = sunPath
    }
    if moonPath != "" {
        state.moon_asset = moonPath
    }
    if daySkyPath != "" {
        state.day_sky_asset = daySkyPath
    }
    if nightSkyPath != "" {
        state.night_sky_asset = nightSkyPath
    }
}

GetLocalDayFraction :: proc() -> f32 {
    now := os.time()
    seconds := int(now % 86400)
    return f32(seconds) / 86400.0
}

UpdateLighting :: proc(state: ^LightingState, dt: f32) {
    if state.use_location_time {
        state.time_of_day = GetLocalDayFraction()
    } else {
        total := state.day_length + state.night_length
        if total <= 0.0 {
            total = 1.0
        }
        state.current_cycle += dt
        if state.current_cycle >= total {
            state.current_cycle -= total
        }
        state.time_of_day = state.current_cycle / total
    }

    dayRatio := state.time_of_day
    if dayRatio < 0.5 {
        state.ambient = 0.6 + 0.4 * (dayRatio * 2.0)
    } else {
        state.ambient = 0.6 + 0.4 * (1.0 - (dayRatio-0.5)*2.0)
    }
    if state.ambient < 0.2 {
        state.ambient = 0.2
    }
    if state.ambient > 1.0 {
        state.ambient = 1.0
    }
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

DrawSky :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, screenW, screenH: int, state: LightingState) {
    topR, topG, topB := u8(24), u8(52), u8(102)
    botR, botG, botB := u8(64), u8(110), u8(190)
    if state.time_of_day >= 0.5 {
        topR, topG, topB = 8, 12, 32
        botR, botG, botB = 18, 24, 58
    }
    for y := 0; y < screenH; y += 16 {
        ratio := f32(y) / f32(screenH)
        r := u8(f32(topR)*(1.0-ratio) + f32(botR)*ratio)
        g := u8(f32(topG)*(1.0-ratio) + f32(botG)*ratio)
        b := u8(f32(topB)*(1.0-ratio) + f32(botB)*ratio)
        DrawRect(renderer, 0, y, screenW, 16, r, g, b, 255)
    }

    sunX := int(f32(screenW) * (0.5 + 0.4*math.cos(state.time_of_day*2.0*math.pi - math.pi/2)))
    sunY := int(f32(screenH) * (0.25 + 0.2*math.sin(state.time_of_day*2.0*math.pi - math.pi/2)))
    if state.time_of_day < 0.6 {
        DrawRect(renderer, sunX-24, sunY-24, 48, 48, 240, 200, 80, 220)
        if state.sun_asset != "" {
            DrawTextOrPlaceholder(renderer, font, "Sun:" + state.sun_asset, 40, 40)
        }
    } else {
        DrawRect(renderer, sunX-18, sunY-18, 36, 36, 220, 220, 240, 220)
        if state.moon_asset != "" {
            DrawTextOrPlaceholder(renderer, font, "Moon:" + state.moon_asset, 40, 40)
        }
        for i := 0; i < 30; i += 1 {
            sx := 40 + (i * 37) % (screenW - 80)
            sy := 80 + (i * 21) % (screenH/2)
            DrawRect(renderer, sx, sy, 2, 2, 255, 255, 255, 200)
        }
    }

    if state.day_sky_asset != "" {
        DrawTextOrPlaceholder(renderer, font, "DaySky:" + state.day_sky_asset, 40, screenH - 80)
    }
    if state.night_sky_asset != "" {
        DrawTextOrPlaceholder(renderer, font, "NightSky:" + state.night_sky_asset, 40, screenH - 52)
    }
}
