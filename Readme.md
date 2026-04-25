 Wayland-friendly Linux desktop environment prototype written in Odin, inspired by MMO game UI and game screen layouts.

## What this is

- A base desktop shell layout for Wayland using SDL2.
- A simple UI renderer with a dock, status bar, and desktop widgets.
- A foundation to expand into a full game-themed Linux desktop environment.

## Files

- `main.odin` - entrypoint with desktop UI rendering and event loop.
- `README.md` - project overview.
- `.gitignore` - ignores build artifacts.

## Requirements

- Odin compiler installed on Linux.
- SDL2 development libraries available.
- Optional: Wayland session or SDL2 configured to use Wayland.

## Build and run

```sh
odin run main.odin
```

If you are in a Wayland session, SDL2 should automatically use Wayland when `WAYLAND_DISPLAY` is set.

To force SDL2 to use Wayland:

```sh
SDL_VIDEODRIVER=wayland WAYLAND_DISPLAY=wayland-0 odin run main.odin
```

If you are running under X11, use:

```sh
DISPLAY=:0 odin run main.odin
```

This app now auto-detects the desktop resolution and prints the active SDL video driver at startup. It also attempts to load `DejaVuSans.ttf` from the system font directory for real text rendering.

The desktop now renders floating window panels on top of the main background, so windows can appear as desktop UI elements.

A Settings Manager GUI is available via the Settings button or by pressing `S`.

Settings let users change the desktop theme, select wallpaper/game-world/MMO background modes, toggle the clock, and lock or unlock panel movement.

Press `R` to randomize the world seed when the seed is unlocked.
Press `I` to import models from `GAMEUI_MODEL_PATH` or `GAMEUI_MODEL_PATHS`.
Press `Alt+Tab` to cycle the active window and bring it to the front.

Press `F` to toggle the current window to fullscreen, which also forces a simplified wallpaper-style desktop background to reduce GPU load while a fullscreen app is active.

## Notes

- This is a prototype UI; text is currently rendered with placeholder rectangles.
- Add `SDL_ttf` support later to render real text labels and game UI fonts.
- Model import is supported via environment variables and accepts `.obj`, `.fbx`, `.gltf`, `.glb`, `.dae`, `.stl`, `.ply`, `.3ds`, and `.blend` placeholders.

## Next steps

- Add interactive desktop windows, clickable icons, and animated transitions.
- Integrate SDL_ttf for real text rendering.
- Expand the shell with workspaces, notifications, and app launching.
