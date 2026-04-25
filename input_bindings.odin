package game_desktop

import "core:os"

InputState :: struct {
	keys: []bool,
	mouse_x: i32,
	mouse_y: i32,
	mouse_buttons: []bool,
}

InputBind :: struct {
	action: string,
	key: i32,
	mod: i32,
}

InputBindings :: struct {
	binds: []InputBind,
}

InitInputBindings :: proc() -> InputBindings {
	return InputBindings{}
}

HandleInput :: proc(input: ^InputState, bindings: InputBindings) {
}

GetKeyState :: proc(key: i32) -> bool {
	return false
}

IsKeyPressed :: proc(key: i32) -> bool {
	return false
}

IsKeyReleased :: proc(key: i32) -> bool {
	return false
}

GetMouseX :: proc() -> i32 {
	return 0
}

GetMouseY :: proc() -> i32 {
	return 0
}

IsMouseButtonPressed :: proc(button: i32) -> bool {
	return false
}

LoadBindingsFromFile :: proc(path: string) -> InputBindings {
	return InitInputBindings()
}

SaveBindingsToFile :: proc(bindings: InputBindings, path: string) {
}