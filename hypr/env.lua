-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_DATA_DIRS",       "/usr/local/share:/usr/share")

hl.env("MOZ_ENABLE_WAYLAND", "1")

hl.env("XCURSOR_SIZE",   "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME",  "Adwaita")

-- Theming is deliberately NOT forced from here.
--
-- GTK reads the theme from gsettings (org.gnome.desktop.interface) and
-- ~/.config/gtk-{3,4}.0/settings.ini, which xdg-desktop-portal then exposes to
-- sandboxed and non-Hyprland-launched apps alike. Setting GTK_THEME here would
-- override all of that, and would only reach processes spawned by Hyprland.
--
-- Do not re-add: GTK_THEME (hard override, defeats the portal),
-- GSETTINGS_SCHEMA_DIR (already the default; shadows app-provided schemas), or
-- GTK2_RC_FILES (GTK2 reads ~/.gtkrc-2.0 by default anyway).
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.env("GDK_BACKEND",   "wayland,x11")
hl.env("GTK_USE_PORTAL", "1")
