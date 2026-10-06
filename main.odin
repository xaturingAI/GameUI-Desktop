package game_desktop

import "core:fmt"
import "core:os"
import "vendor:sdl2"
import "vendor:sdl2/ttf"
import "planes"
import "launcher"
import "clock"
import "settings"
import "app_window"
import "world"
import "lighting"
import "models"
import "model_editor"
import "app_registry"
import "xdg"
import "input_bindings"
import "desktop_shell"
import "camera"
import "vulkan_renderer"
import "vulkan_backend"
import "scene"
import "model_loader"

ScreenWidth: int = 1280
ScreenHeight: int = 720

DrawRect :: proc(renderer: ^sdl.Renderer, x, y, w, h: int, r, g, b, a: u8) {
    rect := sdl.Rect{x, y, w, h}
    sdl.set_render_draw_color(renderer, r, g, b, a)
    sdl.render_fill_rect(renderer, &rect)
}

DrawTextPlaceholder :: proc(renderer: ^sdl.Renderer, x, y, text: string) {
    DrawRect(renderer, x, y, int(len(text)) * 9 + 20, 28, 80, 80, 80, 200)
}

DrawText :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, text: string, x, y: int) {
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
}

DrawTextOrPlaceholder :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, text: string, x, y: int) {
    if font != nil {
        DrawText(renderer, font, text, x, y)
    } else {
        DrawTextPlaceholder(renderer, x, y, text)
    }
}

DrawIcon :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, x, y: int, label: string) {
    DrawRect(renderer, x, y, 88, 88, 32, 56, 100, 255)
    DrawTextOrPlaceholder(renderer, font, label, x + 10, y + 30)
}

LoadFont :: proc(path: string, size: int) -> ^sdl_ttf.Font {
    font := sdl_ttf.open_font(path, size)
    if font == nil {
        fmt.println("Font load failed:", sdl_ttf.get_error())
    }
    return font
}

GetDesktopResolution :: proc() -> (int, int) {
    mode := sdl.DisplayMode{}
    if sdl.get_desktop_display_mode(0, &mode) == 0 {
        w := int(mode.w)
        h := int(mode.h)
        return w, h
    }
    return ScreenWidth, ScreenHeight
}

GetDisplayName :: proc() -> string {
    if sdl.get_num_video_displays() > 0 {
        name := sdl.get_display_name(0)
        if name != "" {
            return name
        }
    }
    return "unknown"
}

GetThemeColors :: proc(theme: int) -> (u8, u8, u8, u8, u8, u8) {
    switch theme {
    case 1:
        return u8(8), u8(12), u8(22), u8(18), u8(28), u8(58)
    case 2:
        return u8(18), u8(8), u8(42), u8(82), u8(28), u8(168)
    case 3:
        return u8(14), u8(24), u8(44), u8(26), u8(40), u8(70)
    case 4:
        return u8(20), u8(30), u8(50), u8(30), u8(50), u8(80)
    case 5:
        return u8(30), u8(20), u8(60), u8(40), u8(60), u8(100)
    case 6:
        return u8(10), u8(20), u8(40), u8(20), u8(40), u8(60)
    case 0, -1:
        return u8(14), u8(24), u8(44), u8(26), u8(40), u8(70)
    }
}

DateTimeLabel :: proc() -> string {
    return clock.GetCurrentTimeString()
}

DrawGauge :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, x, y, w, h: int, pct: f32, label: string, r, g, b: u8) {
    if pct < 0.0 { pct = 0.0 }
    if pct > 1.0 { pct = 1.0 }
    DrawRect(renderer, x, y, w, h, 24, 32, 56, 220)
    DrawRect(renderer, x + 4, y + 4, int((w - 8) * pct), h - 8, r, g, b, 255)
    DrawTextOrPlaceholder(renderer, font, label, x + 8, y + 6)
}

DrawMiniMap :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, x, y: int) {
    DrawRect(renderer, x, y, 184, 184, 18, 22, 36, 230)
    DrawRect(renderer, x + 8, y + 8, 168, 168, 12, 16, 26, 255)
    DrawTextOrPlaceholder(renderer, font, "Minimap", x + 14, y + 12)
}

DrawActionBar :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, x, y, w, h: int, icons: []string) {
    DrawRect(renderer, x, y, w, h, 12, 18, 30, 220)
    DrawRect(renderer, x, y, w, 32, 26, 40, 64, 255)
    DrawTextOrPlaceholder(renderer, font, "Action Bar", x + 16, y + 8)
    slotSize := 58
    for i := 0; i < len(icons); i += 1 {
        icon := icons[i]
        ix := x + 14 + i * (slotSize + 10)
        iy := y + 40
        DrawRect(renderer, ix, iy, slotSize, slotSize, 30, 44, 70, 255)
        DrawTextOrPlaceholder(renderer, font, icon, ix + 6, iy + 18)
    }
}

DrawMMOOverlay :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, settingsState: settings.SettingsState) {
    bgR, bgG, bgB, panelR, panelG, panelB := GetThemeColors(settingsState.theme)
    DrawRect(renderer, 100, 12, ScreenWidth - 212, 76, panelR, panelG, panelB, 220)
    DrawGauge(renderer, font, 116, 26, 320, 24, 0.76, "Health", 200, 32, 32)
    DrawGauge(renderer, font, 116, 56, 320, 24, 0.52, "Mana", 32, 96, 200)
    DrawGauge(renderer, font, 460, 26, 300, 24, 0.34, "XP", 230, 200, 40)
    DrawMiniMap(renderer, font, ScreenWidth - 216, 12)
    DrawRect(renderer, 104, ScreenHeight - 132, ScreenWidth - 220, 110, panelR, panelG, panelB, 220)
    DrawActionBar(renderer, font, 120, ScreenHeight - 122, ScreenWidth - 260, 96, []string{"A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8"})
}

DrawDesktop :: proc(renderer: ^sdl.Renderer, font: ^sdl_ttf.Font, shellState: desktop_shell.DesktopShellState, planes: []planes.Plane, activePlane: int, launcher: launcher.AppLauncher, settingsState: settings.SettingsState, worldState: world.WorldState, modelManager: models.ModelManager, editorState: model_editor.ModelEditorState, camState: camera.Camera, lightingState: lighting.LightingState) {
    bgR, bgG, bgB, panelR, panelG, panelB := GetThemeColors(settingsState.theme)

    fullScreenActive := desktop_shell.AnyFullScreenOpen(shellState)
    world.DrawDesktopBackground(renderer, font, settingsState.background_mode, fullScreenActive, ScreenWidth, ScreenHeight, worldState, modelManager, lightingState)

    DrawRect(renderer, 0, 0, 84, ScreenHeight, 14, 20, 36, 220)
    DrawRect(renderer, 32, 12, 118, 32, 36, 52, 92, 255)
    DrawTextOrPlaceholder(renderer, font, "Settings", 40, 18)
    DrawIcon(renderer, font, 12, 32, "Menu")
    DrawIcon(renderer, font, 12, 136, "Term")
    DrawIcon(renderer, font, 12, 240, "Files")
    DrawIcon(renderer, font, 12, 344, "Chat")

    DrawRect(renderer, 104, 48, ScreenWidth - 140, ScreenHeight - 140, panelR, panelG, panelB, 200)
    DrawRect(renderer, 104, 48, ScreenWidth - 140, 52, panelR + 10, panelG + 16, panelB + 26, 255)
    DrawTextOrPlaceholder(renderer, font, "Wayland MMORPG UI", 120, 60)
    DrawTextOrPlaceholder(renderer, font, "Action bars, minimap, frames and panels", 120, 100)

    DrawRect(renderer, 120, 140, 360, 240, 28, 42, 70, 220)
    DrawTextOrPlaceholder(renderer, font, "Quest Log", 136, 154)
    DrawRect(renderer, 492, 140, 380, 240, 28, 42, 70, 220)
    DrawTextOrPlaceholder(renderer, font, "Guild Chat", 506, 154)
    DrawRect(renderer, 896, 140, 260, 240, 28, 42, 70, 220)
    DrawTextOrPlaceholder(renderer, font, "Buffs", 910, 154)

    for i, win in shellState.windows {
        if i != shellState.active_index {
            app_window.DrawWindowPane(renderer, font, win, camState, ScreenWidth, ScreenHeight, false)
        }
    }
    if shellState.active_index >= 0 && shellState.active_index < len(shellState.windows) {
        app_window.DrawWindowPane(renderer, font, shellState.windows[shellState.active_index], camState, ScreenWidth, ScreenHeight, true)
    }

    for i, plane in planes {
        planes.DrawPlane(renderer, font, plane, i == activePlane)
    }

    launcher.DrawLauncher(renderer, font, launcher)
    settings.DrawSettings(renderer, font, settingsState)
    model_editor.DrawEditorHUD(renderer, font, modelManager, editorState)

    DrawRect(renderer, 84, ScreenHeight - 70, ScreenWidth - 84, 70, 10, 14, 24, 240)
    DrawTextOrPlaceholder(renderer, font, "Workspace 1", 100, ScreenHeight - 52)
    DrawTextOrPlaceholder(renderer, font, "CPU 12%  RAM 4.8G", 380, ScreenHeight - 52)
    if settingsState.show_clock {
        DrawTextOrPlaceholder(renderer, font, DateTimeLabel(), 820, ScreenHeight - 52)
    }
}

main :: proc() -> int {
    if sdl.init(sdl.INIT_VIDEO) != 0 {
        fmt.println("SDL init failed:", sdl.get_error())
        return 1
    }

    if sdl_ttf.init() != 0 {
        fmt.println("SDL_ttf init failed:", sdl_ttf.get_error())
    }

    wayland := os.getenv("WAYLAND_DISPLAY")
    display := os.getenv("DISPLAY")
    if wayland != "" {
        fmt.println("Wayland session detected:", wayland)
    } else if display != "" {
        fmt.println("X11 display detected:", display)
    } else {
        fmt.println("No display environment detected. Set WAYLAND_DISPLAY or DISPLAY.")
    }

    driver := sdl.get_current_video_driver()
    if driver == "" {
        driver = "unknown"
    }
    fmt.println("SDL video driver:", driver)
    fmt.println("Display name:", GetDisplayName())

    realWidth, realHeight := GetDesktopResolution()
    fmt.println("Detected desktop resolution:", realWidth, "x", realHeight)
    ScreenWidth = realWidth
    ScreenHeight = realHeight

    fontPath := "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    font := LoadFont(fontPath, 18)
    settingsPanel := settings.InitSettings()
    settingsPanel.world_seed = world.RandomSeed()
    worldState := world.InitWorldState(settingsPanel.world_seed, ScreenWidth, ScreenHeight)
    modelManager := models.InitModelManager()
    models.LoadModelsFromEnv(&modelManager)
    lightingState := lighting.InitLightingState()
    lighting.LoadSkyModulesFromEnv(&lightingState)
    editorState := model_editor.InitModelEditor()
    bindings := input_bindings.InitInputBindings()
    
    cameraState := camera.InitCamera()
    camera.SetAspectRatio(&cameraState, ScreenWidth, ScreenHeight)
    cameraInput := camera.InitCameraInput()
    
    vulkanRen := vulkan_renderer.InitVulkanRendererWithSize(ScreenWidth, ScreenHeight)
    useVulkanMode := false
    
    modelLoader := model_loader.InitModelLoader()
    sceneState := scene.InitScene()
    
    playerEntity := scene.CreatePlayer(&sceneState, nil)
    
    scene.AddDirectionalLight(&sceneState, {0.5, -1.0, 0.5}, {1.0, 0.95, 0.9}, 0.8)
    scene.AddPointLight(&sceneState, {10, 5, 10}, {1.0, 0.8, 0.6}, 1.5, 15.0)

    appRegistry := app_registry.InitAppRegistry()
    app_registry.LoadXDGApplications(&appRegistry)
    if len(appRegistry.apps) == 0 {
        app_registry.LoadDefaultApps(&appRegistry)
    }

    shellState := desktop_shell.InitDesktopShell()
    shellState.OpenWindow(app_window.CreateWindowPane("Chat Window", 260, 220, 520, 320, 30, 50, 84))
    shellState.OpenWindow(app_window.CreateWindowPane("System Panel", 820, 220, 480, 280, 26, 42, 68))
    shellState.OpenWindow(app_window.CreateWindowPane("File Manager", 260, 560, 620, 240, 28, 44, 72))

    planesList := []planes.Plane{
        planes.Plane{x = 120, y = 420, width = 440, height = 170, title = "Action Bar 1", locked = false, r = 24, g = 34, b = 66, pinned_apps = []string{"Browser", "Terminal"}},
        planes.Plane{x = 600, y = 420, width = 420, height = 150, title = "Action Bar 2", locked = false, r = 22, g = 32, b = 56, pinned_apps = []string{"Files", "Chat"}},
    }
    planeIndex := 0
    selectedPlane := -1
    draggingPlane := false
    dragOffsetX := 0
    dragOffsetY := 0

    draggingWindow := false
    windowDragOffsetX := 0
    windowDragOffsetY := 0

    launcherPanel := launcher.AppLauncher{x = ScreenWidth - 372, y = 84, width = 352, height = 260, open = false, apps = appRegistry.apps, selected = 0}

    window := sdl.create_window("GameUI Wayland Desktop", sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, ScreenWidth, ScreenHeight, sdl.WINDOW_SHOWN | sdl.WINDOW_RESIZABLE | sdl.WINDOW_ALLOW_HIGHDPI)
    if window == nil {
        fmt.println("Window creation failed: ", sdl.get_error())
        sdl.quit()
        return 1
    }

    renderer := sdl.create_renderer(window, -1, sdl.RENDERER_ACCELERATED | sdl.RENDERER_PRESENTVSYNC)
    if renderer == nil {
        fmt.println("Renderer creation failed: ", sdl.get_error())
        sdl.destroy_window(window)
        sdl.quit()
        return 1
    }

    running := true
    event := sdl.Event{}

    for running {
        for sdl.poll_event(&event) != 0 {
            event_type := event.type
            
            if event_type == sdl.QUIT {
                running = false
            } else if event_type == sdl.MOUSEBUTTONDOWN {
                if event.button.button == sdl.BUTTON_LEFT {
                    mx := int(event.button.x)
                    my := int(event.button.y)
                    if settings.SettingsHit(mx, my) {
                        settings.ToggleSettings(&settingsPanel)
                    }
                    if settingsPanel.open {
                        settings.HandleSettingsClick(&settingsPanel, mx, my)
                    }
                    if launcher.LauncherHit(launcherPanel, mx, my) {
                        if launcherPanel.open {
                            appIndex := launcher.AppIconHit(launcherPanel, mx, my)
                            if appIndex >= 0 && appIndex < len(launcherPanel.apps) {
                                appEntry := launcherPanel.apps[appIndex]
                                desktop_shell.OpenWindow(&shellState, app_window.CreateWindowPane(appEntry.name, 280, 260, 520, 340, 34, 56, 98))
                                if selectedPlane >= 0 && selectedPlane < len(planesList) {
                                    plane := planesList[selectedPlane]
                                    found := false
                                    pin_i := 0
                                    for pin_i < len(plane.pinned_apps) {
                                        pin := plane.pinned_apps[pin_i]
                                        if pin == appEntry.name {
                                            found = true
                                            break
                                        }
                                        pin_i += 1
                                    }
                                    if !found {
                                        plane.pinned_apps = append(plane.pinned_apps, appEntry.name)
                                        planesList[selectedPlane] = plane
                                    }
                                }
                            }
                        }
                    }
                    model_editor.HandleMouseDown(&editorState, &modelManager, mx, my, event.button.button)
                    clickedWindow := false
                    window_i := len(shellState.windows) - 1
                    for window_i >= 0 {
                        if app_window.WindowTitleHit(shellState.windows[window_i], mx, my) {
                            shellState.active_index = window_i
                            clickedWindow = true
                            if app_window.WindowLockHit(shellState.windows[window_i], mx, my) {
                                app_window.ToggleLock(&shellState.windows[window_i])
                            } else if !shellState.windows[window_i].locked && !shellState.windows[window_i].full_screen {
                                draggingWindow = true
                                windowDragOffsetX = mx - shellState.windows[window_i].x
                                windowDragOffsetY = my - shellState.windows[window_i].y
                            }
                            break
                        }
                        window_i -= 1
                    }

                    if !clickedWindow {
                        plane_i := len(planesList) - 1
                        for plane_i >= 0 {
                            if planes.PlaneTitleHit(planesList[plane_i], mx, my) {
                                selectedPlane = plane_i
                                planeIndex = plane_i
                                if planes.PlaneLockHit(planesList[plane_i], mx, my) {
                                    plane := planesList[plane_i]
                                    plane.locked = !plane.locked
                                    planesList[plane_i] = plane
                                } else if !planesList[plane_i].locked {
                                    draggingPlane = true
                                    dragOffsetX = mx - planesList[plane_i].x
                                    dragOffsetY = my - planesList[plane_i].y
                                }
                                break
                            }
                            plane_i -= 1
                        }
                    }
                }
            } else if event_type == sdl.MOUSEBUTTONUP {
                if event.button.button == sdl.BUTTON_LEFT || event.button.button == sdl.BUTTON_RIGHT {
                    draggingPlane = false
                    draggingWindow = false
                    model_editor.HandleMouseUp(&editorState)
                }
            } else if event_type == sdl.MOUSEMOTION {
                mx := int(event.motion.x)
                my := int(event.motion.y)
                model_editor.HandleMouseMotion(&editorState, &modelManager, mx, my)
                if draggingWindow && shellState.active_index >= 0 && shellState.active_index < len(shellState.windows) {
                    win := shellState.windows[shellState.active_index]
                    win.x = mx - windowDragOffsetX
                    win.y = my - windowDragOffsetY
                    if win.x < 90 {
                        win.x = 90
                    }
                    if win.y < 40 {
                        win.y = 40
                    }
                    if win.x+win.width > ScreenWidth-20 {
                        win.x = ScreenWidth - win.width - 20
                    }
                    if win.y+win.height > ScreenHeight-90 {
                        win.y = ScreenHeight - win.height - 90
                    }
                    shellState.windows[shellState.active_index] = win
                }
                if draggingPlane && selectedPlane >= 0 && selectedPlane < len(planesList) {
                    mx := int(event.motion.x)
                    my := int(event.motion.y)
                    plane := planesList[selectedPlane]
                    plane.x = mx - dragOffsetX
                    plane.y = my - dragOffsetY
                    if plane.x < 90 {
                        plane.x = 90
                    }
                    if plane.y < 40 {
                        plane.y = 40
                    }
                    if plane.x+plane.width > ScreenWidth-20 {
                        plane.x = ScreenWidth - plane.width - 20
                    }
                    if plane.y+plane.height > ScreenHeight-90 {
                        plane.y = ScreenHeight - plane.height - 90
                    }
                    planesList[selectedPlane] = plane
                }
                if cameraInput.mouse_captured {
                    dx := f32(event.motion.xrel)
                    dy := f32(event.motion.yrel)
                    cameraInput.look_dx += dx
                    cameraInput.look_dy += dy
                }
            } else if event_type == sdl.KEYDOWN {
                if settingsPanel.awaiting_rebind {
                    if event.key.keysym.sym == sdl.K_ESCAPE {
                        settingsPanel.awaiting_rebind = false
                    } else {
                        settings.SetKeyBinding(&settingsPanel, settingsPanel.rebind_action, int(event.key.keysym.sym))
                        settingsPanel.awaiting_rebind = false
                    }
                } else if event.key.keysym.sym == sdl.K_ESCAPE {
                    running = false
                } else if event.key.keysym.sym == settingsPanel.toggle_settings_key {
                    settings.ToggleSettings(&settingsPanel)
                } else if event.key.keysym.sym == settingsPanel.toggle_launcher_key {
                    launcher.ToggleLauncher(&launcherPanel)
                } else if event.key.keysym.sym == settingsPanel.cycle_windows_key {
                    if len(shellState.windows) > 0 {
                        desktop_shell.CycleWindows(&shellState)
                    }
                } else if event.key.keysym.sym == settingsPanel.close_app_key {
                    desktop_shell.CloseActiveWindow(&shellState)
                } else if event.key.keysym.sym == settingsPanel.lock_window_key {
                    if shellState.active_index >= 0 && shellState.active_index < len(shellState.windows) {
                        app_window.ToggleLock(&shellState.windows[shellState.active_index])
                    }
                } else if event.key.keysym.sym == sdl.K_r {
                    if !settingsPanel.seed_locked {
                        settingsPanel.world_seed = world.RandomSeed()
                        world.UpdateWorldSeed(&worldState, settingsPanel.world_seed)
                    }
                } else if event.key.keysym.sym == sdl.K_i {
                    models.LoadModelsFromEnv(&modelManager)
                    lighting.LoadSkyModulesFromEnv(&lightingState)
                } else if event.key.keysym.sym == sdl.K_m {
                    modelPath := os.getenv("GAMEUI_MODEL_PATH")
                    if modelPath != "" {
                        loaded := model_loader.LoadModel(modelPath)
                        model_loader.UploadToGPU(&loaded)
                        _ = scene.AddEntity(&sceneState, "Loaded", &loaded)
                    }
                } else if event.key.keysym.sym == sdl.K_f {
                    if shellState.active_index >= 0 && shellState.active_index < len(shellState.windows) {
                        app_window.ToggleFullScreen(&shellState.windows[shellState.active_index], ScreenWidth, ScreenHeight)
                    }
                } else if event.key.keysym.sym == sdl.K_l {
                    if selectedPlane >= 0 && selectedPlane < len(planesList) {
                        plane := planesList[selectedPlane]
                        plane.locked = !plane.locked
                        planesList[selectedPlane] = plane
                    }
                } else if event.key.keysym.sym == sdl.K_PLUS || event.key.keysym.sym == sdl.K_EQUALS {
                    if selectedPlane >= 0 && selectedPlane < len(planesList) {
                        plane := planesList[selectedPlane]
                        if !plane.locked {
                            plane.width += 20
                            plane.height += 14
                            planesList[selectedPlane] = plane
                        }
                    }
                } else if event.key.keysym.sym == sdl.K_MINUS {
                    if selectedPlane >= 0 && selectedPlane < len(planesList) {
                        plane := planesList[selectedPlane]
                        if !plane.locked {
                            if plane.width > 160 {
                                plane.width -= 20
                            }
                            if plane.height > 100 {
                                plane.height -= 14
                            }
                            planesList[selectedPlane] = plane
                        }
                    }
                } else if event.key.keysym.sym == sdl.K_u {
                    if selectedPlane >= 0 && selectedPlane < len(planesList) {
                        plane := planesList[selectedPlane]
                        if len(plane.pinned_apps) > 0 {
                            plane.pinned_apps = plane.pinned_apps[:len(plane.pinned_apps)-1]
                            planesList[selectedPlane] = plane
                        }
                    }
                } else if event.key.keysym.sym == sdl.K_w {
                    cameraInput.move_forward = true
                } else if event.key.keysym.sym == sdl.K_s {
                    cameraInput.move_backward = true
                } else if event.key.keysym.sym == sdl.K_a {
                    cameraInput.move_left = true
                } else if event.key.keysym.sym == sdl.K_d {
                    cameraInput.move_right = true
                } else if event.key.keysym.sym == sdl.K_SPACE {
                    cameraInput.move_up = true
                } else if event.key.keysym.sym == sdl.K_LSHIFT {
                    cameraInput.move_down = true
                } else if event.key.keysym.sym == sdl.K_v {
                    placement := vulkan_renderer.CalcWindowPlacement(&vulkanRen, 3.0)
                    if shellState.active_index >= 0 && shellState.active_index < len(shellState.windows) {
                        app_window.ConvertToGaze3D(&shellState.windows[shellState.active_index], cameraState, placement)
                    }
                } else if event.key.keysym.sym == sdl.K_g {
                    if shellState.active_index >= 0 && shellState.active_index < len(shellState.windows) {
                        app_window.ConvertTo2D(&shellState.windows[shellState.active_index], ScreenWidth, ScreenHeight, cameraState)
                    }
                } else if event.key.keysym.sym == sdl.K_TAB {
                    if len(shellState.windows) > 0 {
                        desktop_shell.CycleWindows(&shellState)
                    }
                } else if event.key.keysym.sym == sdl.K_1 {
                    useVulkanMode = !useVulkanMode
                }
                model_editor.HandleKeyDown(&editorState, &modelManager, int(event.key.keysym.sym))
            } else if event_type == sdl.KEYUP {
                if event.key.keysym.sym == sdl.K_w {
                    cameraInput.move_forward = false
                } else if event.key.keysym.sym == sdl.K_s {
                    cameraInput.move_backward = false
                } else if event.key.keysym.sym == sdl.K_a {
                    cameraInput.move_left = false
                } else if event.key.keysym.sym == sdl.K_d {
                    cameraInput.move_right = false
                } else if event.key.keysym.sym == sdl.K_SPACE {
                    cameraInput.move_up = false
                } else if event.key.keysym.sym == sdl.K_LSHIFT {
                    cameraInput.move_down = false
                }
            }

            if settingsPanel.import_models_request {
            models.LoadModelsFromEnv(&modelManager)
            settingsPanel.import_models_request = false
        }

        if settingsPanel.import_sky_request {
            lighting.LoadSkyModulesFromEnv(&lightingState)
            settingsPanel.import_sky_request = false
        }

        lightingState.use_location_time = settingsPanel.use_location_time
        lightingState.day_length = f32(settingsPanel.day_length)
        lightingState.night_length = f32(settingsPanel.night_length)

        lighting.UpdateLighting(&lightingState, 0.016)
        worldState.ambient = lightingState.ambient
        
        camera.UpdateCameraInput(&cameraState, &cameraInput, 0.016)
        vulkan_renderer.UpdateVulkanCamera(&vulkanRen, 0.016)
        
        sceneState.camera.position = cameraState.position
        sceneState.camera.rotation = cameraState.rotation
        
        player := scene.GetEntity(&sceneState, playerEntity)
        if player != nil {
            player.position = cameraState.position
        }
        
        scene.UpdateScene(&sceneState, 0.016)

        sdl.set_render_draw_color(renderer, 14, 24, 44, 255)
        sdl.render_clear(renderer)

        DrawDesktop(renderer, font, shellState, planesList, selectedPlane, launcherPanel, settingsPanel, worldState, modelManager, editorState, cameraState, lightingState)
        
        DrawRect(renderer, 16, 16, 260, 82, 20, 26, 40, 200)
        DrawTextOrPlaceholder(renderer, font, "3D Camera", 24, 24)
        DrawTextOrPlaceholder(renderer, font, camera.GetCameraDebugString(cameraState), 24, 46)
        
        modeStr := "2D"
        if useVulkanMode {
            modeStr = "3D"
        }
        DrawTextOrPlaceholder(renderer, font, fmt.sprint("Mode: ", modeStr), 24, 68)
        DrawTextOrPlaceholder(renderer, font, fmt.sprint("Entities: ", len(sceneState.entities)), 24, 90)

        sdl.render_present(renderer)
        sdl.delay(16)
    }

    if font != nil {
        sdl_ttf.close_font(font)
    }
    sdl_ttf.quit()
    sdl.destroy_renderer(renderer)
    sdl.destroy_window(window)
    sdl.quit()
    
    scene.FreeScene(&sceneState)
    model_loader.FreeModelLoader(&modelLoader)
    
    return 0
}
}

