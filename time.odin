package game_desktop

import "core:fmt"
import "core:os"

GetCurrentTimeString :: proc() -> string {
    now := os.time()
    local := os.local_time(now)
    return fmt.sprintf("%02d:%02d:%02d", local.hour, local.minute, local.second)
}
