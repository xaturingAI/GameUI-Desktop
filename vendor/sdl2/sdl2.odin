// Minimal SDL2 bindings using system SDL2
package sdl2

import "core:c"

when ODIN_OS == "windows" {
	foreign import lib "SDL2.lib"
} else {
	foreign import lib "system:SDL2"
}

InitFlag :: enum u32 {
	TIMER          =  0x00,
	AUDIO          =  0x04,
	VIDEO          =  0x05,
	JOYSTICK       =  0x09,
	HAPTIC         =  0x0c,
	GAMECONTROLLER =  0x0d,
	EVENTS         =  0x0e,
	NOPARACHUTE    =  0x14,
}

InitFlags :: bit_set[InitFlag; u32]

INIT_TIMER          :: InitFlags{.TIMER}
INIT_AUDIO          :: InitFlags{.AUDIO}
INIT_VIDEO          :: InitFlags{.VIDEO}
INIT_JOYSTICK       :: InitFlags{.JOYSTICK}
INIT_HAPTIC         :: InitFlags{.HAPTIC}
INIT_GAMECONTROLLER :: InitFlags{.GAMECONTROLLER}
INIT_EVENTS         :: InitFlags{.EVENTS}
INIT_EVERYTHING :: InitFlags{.TIMER, .AUDIO, .VIDEO, .EVENTS, .JOYSTICK, .HAPTIC, .GAMECONTROLLER}

@(default_calling_convention="c", link_prefix="SDL_")
foreign lib {
	Init :: proc(flags: InitFlags) -> c.int ---
	Quit :: proc() ---
	GetError :: proc() -> cstring ---
	SetError :: proc(fmt: cstring, #c_vararg args: ..any) -> c.int ---
}

Window :: struct {}
Renderer :: struct {}
Surface :: struct {}
Texture :: struct {}
Rect :: struct {
	x, y: c.int,
	w, h: c.int,
}
Point :: struct {
	x, y: c.int,
}
Color :: struct {
	r, g, b, a: u8,
}

EventType :: enum u32 {
	QUIT = 0x100,
	KEYDOWN = 0x301,
	KEYUP = 0x302,
	MOUSEMOTION = 0x400,
	MOUSEBUTTONDOWN = 0x401,
	MOUSEBUTTONUP = 0x402,
	MOUSEWHEEL = 0x403,
}

Event :: struct #raw_union {
	type: EventType,
	padding: [56]u8,
}

WindowFlags :: enum u32 {
	SHOWN = 0x00000001,
	HIDDEN = 0x00000002,
	BORDERLESS = 0x00000010,
	RESIZABLE = 0x00000020,
	MINIMIZED = 0x00000040,
	MAXIMIZED = 0x00000080,
	MOUSE_GRABBED = 0x00000100,
	INPUT_FOCUS = 0x00000200,
	MOUSE_FOCUS = 0x00000400,
	FULLSCREEN = 0x00000800,
	ALLOW_HIGHDPI = 0x00002000,
	MOUSE_CAPTURE = 0x00004000,
}

RenderFlags :: enum u32 {
	SOFTWARE = 0x00000001,
	ACCELERATED = 0x00000002,
	PRESENTVSYNC = 0x00000004,
	TARGETTEXTURE = 0x00000008,
}

BlendMode :: enum c.int {
	NONE = 0,
	BLEND = 1,
	ADD = 2,
	MOD = 4,
}

KeyCode :: enum u32 {
	K_UNKNOWN = 0,
	K_RETURN = 0x0D,
	K_ESCAPE = 0x1B,
	K_BACKSPACE = 0x08,
	K_TAB = 0x09,
	K_SPACE = 0x20,
	K_EXCLAIM = 0x21,
	K_QUOTEDBL = 0x22,
	K_HASH = 0x23,
	K_PERCENT = 0x25,
	K_AMPERSAND = 0x26,
	K_QUOTE = 0x27,
	K_LEFTPAREN = 0x28,
	K_RIGHTPAREN = 0x29,
	K_ASTERISK = 0x2A,
	K_PLUS = 0x2B,
	K_COMMA = 0x2C,
	K_MINUS = 0x2D,
	K_PERIOD = 0x2E,
	K_SLASH = 0x2F,
	K_0 = 0x30,
	K_1 = 0x31,
	K_2 = 0x32,
	K_3 = 0x33,
	K_4 = 0x34,
	K_5 = 0x35,
	K_6 = 0x36,
	K_7 = 0x37,
	K_8 = 0x38,
	K_9 = 0x39,
	K_COLON = 0x3A,
	K_SEMICOLON = 0x3B,
	K_LESS = 0x3C,
	K_EQUALS = 0x3D,
	K_GREATER = 0x3E,
	K_QUESTION = 0x3F,
	K_AT = 0x40,
	K_LEFTBRACKET = 0x5B,
	K_BACKSLASH = 0x5C,
	K_RIGHTBRACKET = 0x5D,
	K_CARET = 0x5E,
	K_UNDERSCORE = 0x5F,
	K_BACKQUOTE = 0x60,
	K_a = 0x61,
	K_b = 0x62,
	K_c = 0x63,
	K_d = 0x64,
	K_e = 0x65,
	K_f = 0x66,
	K_g = 0x67,
	K_h = 0x68,
	K_i = 0x69,
	K_j = 0x6A,
	K_k = 0x6B,
	K_l = 0x6C,
	K_m = 0x6D,
	K_n = 0x6E,
	K_o = 0x6F,
	K_p = 0x70,
	K_q = 0x71,
	K_r = 0x72,
	K_s = 0x73,
	K_t = 0x74,
	K_u = 0x75,
	K_v = 0x76,
	K_w = 0x77,
	K_x = 0x78,
	K_y = 0x79,
	K_z = 0x7A,
	K_CAPSLOCK = 0x40000039,
	K_F1 = 0x4000003A,
	K_F2 = 0x4000003B,
	K_F3 = 0x4000003C,
	K_F4 = 0x4000003D,
	K_F5 = 0x4000003E,
	K_F6 = 0x4000003F,
	K_F7 = 0x40000040,
	K_F8 = 0x40000041,
	K_F9 = 0x40000042,
	K_F10 = 0x40000043,
	K_F11 = 0x40000044,
	K_F12 = 0x40000045,
	K_PRINTSCREEN = 0x40000046,
	K_SCROLLLOCK = 0x40000047,
	K_PAUSE = 0x40000048,
	K_INSERT = 0x40000049,
	K_HOME = 0x4000004A,
	K_PAGEUP = 0x4000004B,
	K_DELETE = 0x4000004C,
	K_END = 0x4000004D,
	K_PAGEDOWN = 0x4000004E,
	K_RIGHT = 0x4000004F,
	K_LEFT = 0x40000050,
	K_DOWN = 0x40000051,
	K_UP = 0x40000052,
}

Mod :: enum u32 {
	NOMOD = 0x0000,
	LSHIFT = 0x0001,
	RSHIFT = 0x0002,
	CTRL = 0x0040,
	LCTRL = 0x0040,
	RCTRL = 0x2000,
	ALT = 0x0100,
	LALT = 0x0100,
	RALT = 0x1000,
}

@(default_calling_convention="c", link_prefix="SDL_")
foreign lib {
	CreateWindow :: proc(title: cstring, x, y, w, h: c.int, flags: WindowFlags) -> ^Window ---
	DestroyWindow :: proc(window: ^Window) ---
	CreateRenderer :: proc(window: ^Window, index: c.int, flags: RenderFlags) -> ^Renderer ---
	DestroyRenderer :: proc(renderer: ^Renderer) ---
	RenderClear :: proc(renderer: ^Renderer) -> c.int ---
	RenderPresent :: proc(renderer: ^Renderer) ---
	PumpEvents :: proc() ---
	PollEvent :: proc(event: ^Event) -> c.int ---
	GetKeyboardState :: proc(numkeys: ^c.int) -> ^u8 ---
	GetModState :: proc() -> Mod ---
	SetModState :: proc(modstate: Mod) ---
	GetMouseState :: proc(x, y: ^c.int) -> u32 ---
	GetGlobalMouseState :: proc(x, y: ^c.int) -> u32 ---
	ShowCursor :: proc() -> c.int ---
	HideCursor :: proc() -> c.int ---
	WarpMouseInWindow :: proc(window: ^Window, x, y: c.int) ---
	SetWindowTitle :: proc(window: ^Window, title: cstring) ---
	SetWindowSize :: proc(window: ^Window, w, h: c.int) ---
	SetWindowPosition :: proc(window: ^Window, x, y: c.int) ---
	GetWindowPosition :: proc(window: ^Window, x, y: ^c.int) ---
	GetWindowSize :: proc(window: ^Window, w, h: ^c.int) ---
	SetRenderDrawColor :: proc(renderer: ^Renderer, r, g, b, a: u8) -> c.int ---
	RenderFillRect :: proc(renderer: ^Renderer, rect: ^Rect) -> c.int ---
	RenderCopy :: proc(renderer: ^Renderer, texture: ^Texture, srcrect, dstrect: ^Rect) -> c.int ---
	CreateTextureFromSurface :: proc(renderer: ^Renderer, surface: ^Surface) -> ^Texture ---
	DestroyTexture :: proc(texture: ^Texture) ---
	CreateTexture :: proc(renderer: ^Renderer, format: c.uint, access: c.int, w, h: c.int) -> ^Texture ---
	QueryTexture :: proc(texture: ^Texture, format: ^c.uint, access: ^c.int, w, h: ^c.int) -> c.int ---
	RenderCopyEx :: proc(renderer: ^Renderer, texture: ^Texture, srcrect, dstrect: ^Rect, angle: f64, center: ^Point, flip: c.int) -> c.int ---
	LoadBMP :: proc(file: cstring) -> ^Surface ---
	CreateRGBSurface :: proc(flags: u32, w, h, depth: c.int, Rmask, Gmask, Bmask, Amask: u32) -> ^Surface ---
	CreateRGBSurfaceFrom :: proc(pixels: rawptr, w, h, depth: c.int, pitch: c.int, Rmask, Gmask, Bmask, Amask: u32) -> ^Surface ---
	GetRendererOutputSize :: proc(renderer: ^Renderer, w, h: ^c.int) -> c.int ---
	GetNumVideoDisplays :: proc() -> c.int ---
	GetDisplayName :: proc(displayIndex: c.int) -> cstring ---
	GetDisplayBounds :: proc(displayIndex: c.int, rect: ^Rect) -> c.int ---
	GetDesktopDisplayMode :: proc(displayIndex: c.int, mode: ^DisplayMode) -> c.int ---
	GetCurrentDisplayMode :: proc(displayIndex: c.int, mode: ^DisplayMode) -> c.int ---
	GetNumVideoDrivers :: proc() -> c.int ---
	GetVideoDriver :: proc(index: c.int) -> cstring ---
	GetNumRenderers :: proc(displayIndex: c.int) -> c.int ---
	GetRenderDriverInfo :: proc(index: c.int, info: ^RendererInfo) -> c.int ---
	CreateWindowAndRenderer :: proc(width, height: c.int, windowFlags: WindowFlags, window: ^^Window, renderer: ^^Renderer) -> c.int ---
	GetWindowFromID :: proc(id: u32) -> ^Window ---
	GetWindowID :: proc(window: ^Window) -> u32 ---
	SetWindowFullscreen :: proc(window: ^Window, flags: u32) -> c.int ---
	FreeFormat :: proc(format: ^PixelFormat) ---
	FreeSurface :: proc(surface: ^Surface) ---
	GetPixelFormatName :: proc(format: u32) -> cstring ---
	GetNumPixelFormats :: proc() -> c.int ---
	GetPixelFormatEnum :: proc(red: u8, green: u8, blue: u8, alpha: u8) -> u32 ---
	GetRGB :: proc(format: u32, pixel: u32, r, g, b: ^u8) ---
	GetRGBA :: proc(format: u32, pixel: u32, r, g, b, a: ^u8) ---
	MapRGB :: proc(format: ^PixelFormat, r, g, b: u8) -> u32 ---
	MapRGBA :: proc(format: ^PixelFormat, r, g, b, a: u8) -> u32 ---
	AllocFormat :: proc(format: u32) -> ^PixelFormat ---
	AllocPalette :: proc(ncolors: c.int) -> ^Palette ---
	SetWindowBrightness :: proc(window: ^Window, brightness: f32) -> c.int ---
	GetWindowBrightness :: proc(window: ^Window) -> f32 ---
	SetWindowOpacity :: proc(window: ^Window, opacity: f32) -> c.int ---
	GetWindowOpacity :: proc(window: ^Window, opacity: ^f32) -> c.int ---
	SetWindowGammaRamp :: proc(window: ^Window, red, green, blue: [^]u16) -> c.int ---
	GetWindowGammaRamp :: proc(window: ^Window, red, green, blue: [^]u16) -> c.int ---
	HasWindowSurface :: proc(window: ^Window) -> bool ---
	GetWindowSurface :: proc(window: ^Window) -> ^Surface ---
	UpdateWindowSurface :: proc(window: ^Window) -> c.int ---
	SetWindowResizable :: proc(window: ^Window, resizable: bool) ---
	SetWindowAlwaysOnTop :: proc(window: ^Window, on-top: bool) ---
	SetWindowBordered :: proc(window: ^Window, bordered: bool) ---
	SetWindowSize :: proc(window: ^Window, w, h: c.int) ---
	ShowWindow :: proc(window: ^Window) ---
	HideWindow :: proc(window: ^Window) ---
	RaiseWindow :: proc(window: ^Window) ---
	FocusWindow :: proc(window: ^Window) ---
	MaximizeWindow :: proc(window: ^Window) ---
	MinimizeWindow :: proc(window: ^Window) ---
	RestoreWindow :: proc(window: ^Window) ---
	SetWindowMouseRect :: proc(window: ^Window, rect: ^Rect) ---
	GetWindowMinimumSize :: proc(window: ^Window, w, h: ^c.int) ---
	SetWindowMinimumSize :: proc(window: ^Window, w, h: c.int) ---
	GetWindowMaximumSize :: proc(window: ^Window, w, h: ^c.int) ---
	SetWindowMaximumSize :: proc(window: ^Window, w, h: c.int) ---
	GetWindowTitle :: proc(window: ^Window) -> cstring ---
	GetWindowFlags :: proc(window: ^Window) -> WindowFlags ---
}

DisplayMode :: struct {
	format: u32,
	w: c.int,
	h: c.int,
	refresh_rate: c.int,
	driverdata: rawptr,
}

PixelFormat :: struct {}
Palette :: struct {}
RendererInfo :: struct {
	name: cstring,
	flags: RenderFlags,
	num_texture_formats: u32,
	texture_formats: [16]u32,
	max_texture_width: c.int,
	max_texture_height: c.int,
}

KeySym :: struct {
	scancode: c.int,
	sym: KeyCode,
	mod: Mod,
	unicode: u32,
}

KeyboardEvent :: struct {
	type: EventType,
	timestamp: u32,
	windowID: u32,
	state: u8,
	padding1: u8,
	padding2: u8,
	padding3: u8,
	keysym: KeySym,
}

MouseMotionEvent :: struct {
	type: EventType,
	timestamp: u32,
	windowID: u32,
	which: u32,
	x: u32,
	y: u32,
	xrel: i32,
	yrel: i32,
	padding1: u8,
	padding2: u8,
	padding3: u8,
	padding4: u8,
}

MouseButtonEvent :: struct {
	type: EventType,
	timestamp: u32,
	windowID: u32,
	which: u32,
	button: u8,
	state: u8,
	clicks: u8,
	padding1: u8,
	x: i32,
	y: i32,
}

QuitEvent :: struct {
	type: EventType,
	timestamp: u32,
}

Delay :: proc(ms: u32) ---
	GetTicks :: proc() -> u32 ---
	GetPerformanceCounter :: proc() -> u64 ---
	GetPerformanceFrequency :: proc() -> u64 ---
	TICKS_PASSED_SECOND :: f64(1000.0)