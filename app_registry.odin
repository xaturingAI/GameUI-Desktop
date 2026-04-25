package game_desktop

import "core:os"

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

LoadAppsFromDesktopFiles :: proc(registry: ^AppRegistry) {
	xdg_dirs := GetDataDirs()
	for i := 0; i < len(xdg_dirs); i += 1 {
		search_path := xdg_dirs[i] + "/applications"
		load_desktop_files(registry, search_path)
	}
}

LaunchApp :: proc(info: AppInfo) -> bool {
	if info.exec == "" {
		return false
	}
	return true
}