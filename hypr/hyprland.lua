-- Hyprland configuration.
-- https://wiki.hypr.land/Configuring/
--
-- Migrated from hyprland.conf (hyprlang) to Lua. hyprlang was deprecated in
-- Hyprland 0.55 and the binary warns that ".conf" support is removed in 0.57:
--
--     strings /usr/bin/Hyprland | grep 'removed in Hyprland'
--
-- Reference material ships with the package, and is more reliable than the
-- wiki for exact field names:
--   /usr/share/hypr/hyprland.lua        -- upstream example config
--   /usr/share/hypr/stubs/hl.meta.lua   -- typed API stub (every option/field)
--
-- Note only the *compositor* moved to Lua. hyprlock.conf, hypridle.conf and
-- hyprpaper.conf belong to separate Hypr* projects and are still hyprlang.
--
-- Each required file gets its own Lua scope, so a syntax error in one module
-- does not take down the whole config. `require` paths are relative to this
-- file and use "/" as the separator.

require("env")
require("monitors")
require("looknfeel")
require("rules")
require("autostart")
require("binds")
