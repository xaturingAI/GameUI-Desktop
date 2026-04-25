// Minimal SDL2_ttf bindings
package sdl_ttf

import "core:c"

when ODIN_OS == "windows" {
	foreign import lib "SDL2_ttf.lib"
} else {
	foreign import lib "system:SDL2_ttf"
}

@(default_calling_convention="c", link_prefix="TTF_")
foreign lib {
	Init :: proc() -> c.int ---
	Quit :: proc() ---
	OpenFont :: proc(file: cstring, ptsize: c.int) -> ^Font ---
	OpenFontIndex :: proc(file: cstring, ptsize: c.int, index: c.int) -> ^Font ---
	CloseFont :: proc(font: ^Font) ---
	RenderText_Solid :: proc(font: ^Font, text: cstring, fg: Color) -> ^Surface ---
	RenderUTF8_Solid :: proc(font: ^Font, text: cstring, fg: Color) -> ^Surface ---
	RenderText_Blended :: proc(font: ^Font, text: cstring, fg: Color) -> ^Surface ---
	RenderUTF8_Blended :: proc(font: ^Font, text: cstring, fg: Color) -> ^Surface ---
	RenderText_Shaded :: proc(font: ^Font, text: cstring, fg, bg: Color) -> ^Surface ---
	RenderUTF8_Shaded :: proc(font: ^Font, text: cstring, fg, bg: Color) -> ^Surface ---
	GetError :: proc() -> cstring ---
	SetError :: proc(fmt: cstring, #c_vararg args: ..any) -> c.int ---
	GetFontRect :: proc(font: ^Font) -> Rect ---
	GetFontAscent :: proc(font: ^Font) -> c.int ---
	GetFontDescent :: proc(font: ^Font) -> c.int ---
	GetFontLineSkip :: proc(font: ^Font) -> c.int ---
	GetFontFaces :: proc(font: ^Font) -> c.int ---
	FaceIsFixedWidth :: proc(font: ^Font) -> bool ---
	GetFontFaceFamilyName :: proc(font: ^Font) -> cstring ---
	GetFontFaceStyleName :: proc(font: ^Font) -> cstring ---
	GetFontGlyphIndex :: proc(font: ^Font, ch: u32) -> u32 ---
	GetFontGlyphMetrics :: proc(font: ^Font, ch: u32, minx, maxx, miny, maxy, advance: ^c.int) -> c.int ---
	GetTextSize :: proc(font: ^Font, text: cstring, w, h: ^c.int) ---
}

Font :: struct {}
Rect :: struct {
	x: c.int,
	y: c.int,
	w: c.int,
	h: c.int,
}

Color :: struct {
	r: u8,
	g: u8,
	b: u8,
	a: u8,
}