-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

local colors = require("theme/colors")

hl.config({
    general = {
        gaps_in  = 2.5,
        gaps_out = 5,

        border_size = 2,

        col = {
            active_border   = colors.active_border,
            inactive_border = colors.inactive_border,
        },

        -- Set to true to enable resizing windows by clicking and dragging on
        -- borders and gaps.
        resize_on_border = false,

        -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Transparency of focused and unfocused windows.
        active_opacity   = 1.0,
        inactive_opacity = 0.75,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = colors.shadow,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
    dwindle = {
        -- `pseudotile` was removed as a config option upstream; pseudotiling is
        -- now only a dispatcher, bound to SUPER+P in binds.lua.
        preserve_split = true,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,    -- 0 or 1 disables the anime mascot wallpapers
        disable_hyprland_logo   = false, -- true disables the random hyprland logo background

        -- Both default to FALSE upstream, which makes a DPMS-off screen
        -- unrecoverable from the console: no keypress and no mouse move wake
        -- the displays, only SSH. hypridle blanks them on idle
        -- (hypridle.conf's 1200s listener), so leaving these unset turns every
        -- idle desktop into a lockout -- and it did, twice.
        --
        -- These MUST stay true for as long as anything dispatches dpms off.
        -- Verify with: hyprctl -j getoption misc:key_press_enables_dpms
        -- (`"set": true` is the assertion that matters, not just the value).
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,
    },

    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Animation curves. hyprlang took four flat numbers
-- (`bezier = name,x1,y1,x2,y2`); Lua takes them as two control points.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1.0 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- "Smart gaps" / "No gaps when only" -- uncomment all if you want it.
-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
