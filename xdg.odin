package game_desktop

import "core:fmt"
import "core:os"
import "core:strings"

AppInfo :: struct {
	id: string,
	name: string,
	icon: string,
	exec: string,
	categories: []string,
}

XDG_DIRS :: proc() -> []string {
	home := os.get_env("HOME")
	xdg_config := os.get_env("XDG_CONFIG_HOME")
	xdg_data := os.get_env("XDG_DATA_HOME")
	xdg_cache := os.get_env("XDG_CACHE_HOME")
	
	dirs := []string{}
	
	if xdg_config != "" {
		dirs = append(dirs, xdg_config)
	} else {
		dirs = append(dirs, home + "/.config")
	}
	
	if xdg_data != "" {
		dirs = append(dirs, xdg_data)
	} else {
		dirs = append(dirs, home + "/.local/share")
	}
	
	if xdg_cache != "" {
		dirs = append(dirs, xdg_cache)
	} else {
		dirs = append(dirs, home + "/.cache")
	}
	
	dirs = append(dirs, home + "/.config")
	dirs = append(dirs, home + "/.local/share")
	dirs = append(dirs, home + "/.local/bin")
	
	return dirs
}

GetConfigDir :: proc() -> string {
	config := os.get_env("XDG_CONFIG_HOME")
	if config != "" {
		return config
	}
	home := os.get_env("HOME")
	return home + "/.config"
}

GetDataDir :: proc() -> string {
	data := os.get_env("XDG_DATA_HOME")
	if data != "" {
		return data
	}
	home := os.get_env("HOME")
	return home + "/.local/share"
}

GetCacheDir :: proc() -> string {
	cache := os.get_env("XDG_CACHE_HOME")
	if cache != "" {
		return cache
	}
	home := os.get_env("HOME")
	return home + "/.cache"
}

GetRuntimeDir :: proc() -> string {
	runtime := os.get_env("XDG_RUNTIME_DIR")
	if runtime != "" {
		return runtime
	}
	return "/tmp"
}

EnsureConfigDirExists :: proc(subdir: string) {
	config := GetConfigDir()
	path := config + "/" + subdir
	os.make_directory(path)
}

EnsureDataDirExists :: proc(subdir: string) {
	data := GetDataDir()
	path := data + "/" + subdir
	os.make_directory(path)
}

ParseDesktopFile :: proc(path: string) -> AppInfo {
	info := AppInfo{}
	content, ok := os.read_entire_file(path)
	if !ok {
		return info
	}
	
	info.id = path
	
	lines := strings.split(content, "\n")
	defer delete(lines)
	
	for line in lines {
		line = strings.trim_space(line)
		if strings.has_prefix(line, "#") || line == "" {
			continue
		}
		
		if strings.has_prefix(line, "Name=") {
			info.name = strings.trim_space(strings.slice_to(line, "="))
		} else if strings.has_prefix(line, "Exec=") {
			info.exec = strings.trim_space(strings.slice_to(line, "="))
		} else if strings.has_prefix(line, "Icon=") {
			info.icon = strings.trim_space(strings.slice_to(line, "="))
		} else if strings.has_prefix(line, "Categories=") {
			cats := strings.trim_space(strings.slice_to(line, "="))
			info.categories = strings.split(cats, ";")
		}
	}
	
	return info
}