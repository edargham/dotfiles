-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({ output = "DP-1",     mode = "1920x1080@60", position = "0x0",    scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "1920x0", scale = 1 })

-- Fallback for anything else that gets plugged in.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- MONITOR LAYOUT
--
-- Left monitor (DP-1) owns the odd workspaces, right monitor (HDMI-A-1) owns
-- the even ones. `default` sets each monitor's startup workspace (DP-1 -> 1,
-- HDMI-A-1 -> 2).
--
-- The SUPER+[0-9] binds in binds.lua need no monitor awareness: Hyprland
-- routes a workspace focus to whichever monitor owns that workspace.
for ws = 1, 10 do
    hl.workspace_rule({
        workspace = tostring(ws),
        monitor   = (ws % 2 == 1) and "DP-1" or "HDMI-A-1",
        default   = ws <= 2,
    })
end
