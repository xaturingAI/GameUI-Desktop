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

AppRegistry :: struct {
	apps: []AppInfo,
}

InitAppRegistry :: proc() -> AppRegistry {
	return AppRegistry{}
}

RegisterApp :: proc(registry: ^AppRegistry, info: AppInfo) {
	registry.apps = append(registry.apps, info)
}

UnregisterApp :: proc(registry: ^AppRegistry, id: string) {
}

GetAppById :: proc(registry: AppRegistry, id: string) -> ^AppInfo {
	for i := 0; i < len(registry.apps); i += 1 {
		if registry.apps[i].id == id {
			return &registry.apps[i]
		}
	}
	return nil
}

GetAppsByCategory :: proc(registry: AppRegistry, category: string) -> []AppInfo {
	result := []AppInfo{}
	for i := 0; i < len(registry.apps); i += 1 {
		app := &registry.apps[i]
		for j := 0; j < len(app.categories); j += 1 {
			if app.categories[j] == category {
				result = append(result, app^)
				break
			}
		}
	}
	return result
}

LoadXDGApplications :: proc(registry: ^AppRegistry) {
	xdg_dirs := XDG_DIRS()
	for i := 0; i < len(xdg_dirs); i += 1 {
		search_path := xdg_dirs[i] + "/applications"
		load_desktop_files(registry, search_path)
	}
}

load_desktop_files :: proc(registry: ^AppRegistry, dir_path: string) {
	file, ok := os.open_directory(dir_path)
	if !ok {
		return
	}
	defer os.close_directory(file)
	
	for os.read_directory(file) {
		entry := os.DirectoryEntry{}
		if !os.read_directory_entry(file, &entry) {
			break
		}
		if strings.has_suffix(entry.name, ".desktop") {
			full_path := dir_path + "/" + entry.name
			info := ParseDesktopFile(full_path)
			if info.name != "" {
				RegisterApp(registry, info)
			}
		}
	}
}

LoadDefaultApps :: proc(registry: ^AppRegistry) {
	default_apps := []AppInfo{
		AppInfo{id = "terminal", name = "Terminal", icon = "utilities-terminal", exec = "gnome-terminal"},
		AppInfo{id = "files", name = "Files", icon = "system-file-manager", exec = "nautilus"},
		AppInfo{id = "browser", name = "Browser", icon = "web-browser", exec = "firefox"},
		AppInfo{id = "chat", name = "Chat", icon = "internet-chat", exec = "element-desktop"},
		AppInfo{id = "settings", name = "Settings", icon = "preferences-system", exec = "gnome-control-center"},
		AppInfo{id = "editor", name = "Text Editor", icon = "accessories-text-editor", exec = "gedit"},
	}
	for i := 0; i < len(default_apps); i += 1 {
		RegisterApp(registry, default_apps[i])
	}
}

LaunchApp :: proc(info: AppInfo) -> bool {
	if info.exec == "" {
		return false
	}
	return true
}