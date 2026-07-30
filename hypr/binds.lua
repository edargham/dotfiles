-- See https://wiki.hypr.land/Configuring/Basics/Binds/
--
-- hyprlang bind flag -> Lua options table:
--   bindm (mouse)          -> { mouse = true }
--   bindel (locked+repeat) -> { locked = true, repeating = true }
--   bindl (locked)         -> { locked = true }

local prog = require("programs")

local mainMod = "SUPER"

-- Launchers
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(prog.terminal))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(prog.alt_terminal))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(prog.browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(prog.file_manager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(prog.gui_file_manager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(prog.menu))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd(prog.steam))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(prog.vscode))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(prog.lock))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd(prog.shot))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd(prog.shot_annotate))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd(prog.picker))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("hyprsysteminfo"))

-- Night mode. Both this and waybar's custom/night-mode module call the same
-- script, which reads/writes the running hyprsunset daemon over IPC -- there is
-- no state file, so the two entry points cannot disagree.
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("~/.config/waybar/night-mode-toggle.sh"))

-- Palette switcher: rofi picker over the curated palettes in
-- wallust/colorschemes plus wallust's ~617 built-in themes. Regenerates every
-- consumer's colours and reloads them in place.
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("~/.config/wallust/theme-switch"))

-- Window management
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())          -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9], move the active window with + SHIFT.
-- Workspace N lives on whichever monitor monitors.lua assigned it to.
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Clipboard history picker
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd('cliphist list | rofi -p "Paste:" -dmenu | cliphist decode | wl-copy'))

-- Volume and brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                           { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                           { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
