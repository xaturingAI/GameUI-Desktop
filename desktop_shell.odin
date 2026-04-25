package game_desktop

import "core:math"

DesktopShellState :: struct {
	windows: []WindowPane,
	active_index: int,
	minimized_count: int,
}

InitDesktopShell :: proc() -> DesktopShellState {
	return DesktopShellState{
		windows = make([]WindowPane, 0),
		active_index = -1,
		minimized_count = 0,
	}
}

OpenWindow :: proc(state: ^DesktopShellState, window: WindowPane) {
	state.windows = append(state.windows, window)
	state.active_index = len(state.windows) - 1
}

CloseActiveWindow :: proc(state: ^DesktopShellState) {
	if state.active_index >= 0 && state.active_index < len(state.windows) {
		state.windows[state.active_index].closed = true
	}
}

CycleWindows :: proc(state: ^DesktopShellState) {
	if len(state.windows) == 0 {
		return
	}
	state.active_index = (state.active_index + 1) % len(state.windows)
}

AnyFullScreenOpen :: proc(state: DesktopShellState) -> bool {
	for win in state.windows {
		if win.full_screen {
			return true
		}
	}
	return false
}

CleanupClosedWindows :: proc(state: ^DesktopShellState) {
	result := []WindowPane{}
	for win in state.windows {
		if !win.closed {
			result = append(result, win)
		}
	}
	if len(result) != len(state.windows) {
		delete(state.windows)
		state.windows = result
		if state.active_index >= len(state.windows) {
			state.active_index = len(state.windows) - 1
		}
	}
}
