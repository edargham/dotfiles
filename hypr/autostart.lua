-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- This replaces the old `exec-once =` lines. Order inside the callback is the
-- order they fire, and matches the order the .conf had.
--
-- NOT started from here (all are `systemctl --user enable`d and pulled in by
-- graphical-session.target, which uwsm owns):
--
--   hypridle, hyprsunset, swaync, hyprpolkitagent
--
-- Starting any of them here too would run a second, competing daemon.
-- hypridle reads ~/.config/hypr/hypridle.conf by default, so it needs no -c.
-- swaync is the subtle one: it ships D-Bus service files with
-- SystemdService=swaync.service, so the first notification request activates
-- the unit even when disabled; a copy started here holds the D-Bus name and the
-- unit dies with "An instance of SwayNotificationCenter is already running!"
-- until it hits its restart limit. If a daemon owns a well-known D-Bus name,
-- let systemd start it.

local prog = require("programs")

hl.on("hyprland.start", function()
    -- HDMI-A-1 is force-disabled during boot (`video=HDMI-A-1:d` in the
    -- systemd-boot entry /boot/loader/entries/arch.conf) so the Plymouth splash
    -- and the login greeter render on the primary monitor (DP-1) only. That
    -- kernel force reports the connector as `disconnected` for the whole
    -- session, and Hyprland cannot enable a disconnected output, so the force
    -- has to be cleared with a DRM re-probe.
    --
    -- That re-probe happens EARLIER, at login, from a pam_exec hook in
    -- /etc/pam.d/greetd -> /usr/local/bin/reenable-hdmi. Doing it before
    -- Hyprland starts lets the ~0.45s probe overlap compositor startup, so both
    -- monitors come up together instead of the second arriving ~1s late (which
    -- is what running it from here caused).
    --
    -- This line is only a FALLBACK for the case where that hook did not fire --
    -- pam_exec is `optional`, so a failure there is silent. It is guarded on
    -- the connector still being disconnected, so on the normal path it does
    -- nothing and cannot cause a second re-probe or a flicker. See memory
    -- nvidia-video-connector-disable.
    hl.exec_cmd([[doas /bin/sh -c 'for f in /sys/class/drm/*-HDMI-A-1/status; do grep -q disconnected "$f" && echo detect > "$f"; done']])

    hl.exec_cmd(prog.alt_terminal)

    -- The session is managed by uwsm (Universal Wayland Session Manager):
    -- greetd launches `uwsm start -e -D Hyprland hyprland.desktop`, which runs
    -- this compositor inside wayland-wm@hyprland.desktop.service and owns
    -- graphical-session{,-pre}.target. `uwsm finalize` exports the compositor's
    -- runtime vars (WAYLAND_DISPLAY, DISPLAY, HYPRLAND_INSTANCE_SIGNATURE) into
    -- the systemd/D-Bus user environment and signals the compositor unit ready
    -- -- this MUST run or the session start times out. Once it runs, uwsm
    -- activates graphical-session.target, which pulls in every enabled WantedBy
    -- unit (hypridle, hyprsunset, swaync, hyprpolkitagent) WITH the correct
    -- environment.
    --
    -- This replaced a manual dbus-update-activation-environment /
    -- import-environment / hyprland-session.target / portal-restart sequence
    -- whose environment race intermittently left waybar and keybind-launched
    -- apps broken on login.
    hl.exec_cmd("uwsm finalize HYPRLAND_INSTANCE_SIGNATURE")

    -- Clipboard history + persistence across app exit.
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")

    hl.exec_cmd("xwaylandvideobridge")
    hl.exec_cmd("waybar")

    -- Wallpaper. This replaced hyprpaper with awww (a swww fork, already
    -- installed), so a theme switch can animate the wallpaper instead of
    -- swapping it instantly. The script starts awww-daemon if needed, waits for
    -- its socket, and sets a per-output image for the active theme.
    -- hyprpaper.conf is left in the repo but is no longer read by anything.
    hl.exec_cmd("~/.config/wallust/set-wallpaper")
end)
