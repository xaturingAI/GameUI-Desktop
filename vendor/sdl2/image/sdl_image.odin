// Minimal SDL2_image bindings
package sdl_image

import "core:c"

when ODIN_OS == "windows" {
	foreign import lib "SDL2_image.lib"
} else {
	foreign import lib "system:SDL2_image"
}

InitFlag :: enum u32 {
	BMP = 0x00000001,
	GIF = 0x00000002,
	JPG = 0x00000004,
	LBM = 0x00000008,
	PCX = 0x00000010,
	PNG = 0x00000020,
	PNM = 0x00000040,
	TGA = 0x00000080,
	TIF = 0x00000100,
	XCF = 0x00000200,
	XPM = 0x00000400,
	XV = 0x00000800,
	WEBP = 0x00001000,
}

@(default_calling_convention="c", link_prefix="IMG_")
foreign lib {
	Init :: proc(flags: u32) -> c.int ---
	Quit :: proc() ---
	Load :: proc(file: cstring) -> ^Surface ---
	Load_RW :: proc(src: ^Rwops, freesrc: c.int) -> ^Surface ---
	LoadTyped_RW :: proc(src: ^Rwops, freesrc: c.int, type: cstring) -> ^Surface ---
	LoadTexture :: proc(renderer: ^Renderer, file: cstring) -> ^Texture ---
	LoadTexture_RW :: proc(renderer: ^Renderer, src: ^Rwops, freesrc: c.int) -> ^Texture ---
	LoadAnimation :: proc(file: cstring) -> ^Surface ---
	IsBMP :: proc(src: ^Rwops) -> c.int ---
	IsGIF :: proc(src: ^Rwops) -> c.int ---
	IsJPG :: proc(src: ^Rwops) -> c.int ---
	IsPNG :: proc(src: ^Rwops) -> c.int ---
	IsWEBP :: proc(src: ^Rwops) -> c.int ---
	IsSVG :: proc(src: ^Rwops) -> c.int ---
	GetError :: proc() -> cstring ---
	SetError :: proc(fmt: cstring, #c_vararg args: ..any) -> c.int ---
}

Surface :: struct {}
Texture :: struct {}
Renderer :: struct {}
Rwops :: struct {}