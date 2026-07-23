# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is `~/.config` on an Arch Linux (Hyprland/Wayland) desktop, tracked with git. There is no build system, no tests, and no application source code — every file here is a live configuration file consumed directly by the corresponding program. Editing a file in this repo changes the user's running desktop environment (after a reload/restart of the relevant program).

There is no README and no existing CLAUDE.md prior to this one.

## Repo scope and .gitignore

Only a subset of `~/.config` is tracked. [.gitignore](.gitignore) excludes machine-local, cache, or secret-bearing directories: `Code/`, `dconf/`, `glib-*/`, `gtk-*/`, `matplotlib/`, `pulse/`, `qalculate/`, `OpenRGB/`, `vlc/`, `warp-terminal/`, `xfce4/`, `inkscape/`, `qt5ct/`, `user-dirs.*`, `QtProject.conf`, `mimeapps.list`, `Kitware/CMakeSetup.conf`, `GIMP/`, `remmina/`, `freerdp/`.

**Every pattern in .gitignore is anchored with a leading `/`.** This matters: an unanchored pattern like `gtk-*/` matches at *any* depth, so it silently excluded `themes/Sweet-Custom/gtk-{2,3,4}.0/` — the actual GTK theme — while still tracking that theme's 3369-file `node_modules`. Keep new patterns anchored to the repo root.

`systemd/` uses a selective ignore: generated `*.target.wants/` state is excluded, but the hand-authored `systemd/user/*.service`, `*.target`, and `*.service.d/*.conf` files ARE tracked via `!` negation rules. Don't assume a path's tracked state from a top-level directory name — run `git check-ignore -v <path>` when in doubt, since ignore rules and tracked state can diverge over time. When adding new config directories, check whether they contain machine-specific state (caches, history, tokens, hardware IDs) before `git add`-ing them; prefer ignoring those and committing only the human-authored settings files. The vendored theme's npm build tree (`themes/Sweet-Custom/node_modules/`, `package-lock.json`, `*.css.map`) is ignored — it's reproducible from `package.json` — while the compiled theme (`gtk-*`, `assets/`, `index.theme`) is tracked.

## Architecture: how the pieces fit together

This is a Hyprland (wlroots Wayland compositor) desktop. The pieces are wired together through [hypr/hyprland.conf](hypr/hyprland.conf), which is the entry point for the whole session:

- **Session startup** (`exec-once` lines in hyprland.conf) launches, in order: a terminal, polkit agent, dbus/systemd environment sync, `hyprland-session.target` activation (see below), xdg-desktop-portal restart, clipboard tooling (`wl-paste`/`cliphist`/`wl-clip-persist`), `swaync` (notifications), `xwaylandvideobridge`, `waybar`, and `hyprpaper` (wallpaper). Long-running daemons that belong to the graphical session — `hypridle` (idle/lock, configured via [hypr/hypridle.conf](hypr/hypridle.conf)) and `hyprsunset` (blue-light filter) — are NOT started from `exec-once`; they are systemd user units pulled in by `graphical-session.target`. Hyprland does not activate that target on its own, so [systemd/user/hyprland-session.target](systemd/user/hyprland-session.target) (`BindsTo=graphical-session.target`) is started from `exec-once` to bring the whole set up. Don't also add an `exec-once` for a daemon that has an enabled unit, or it will run twice.
- **Program variables** (`$terminal`, `$fileManager`, `$menu`, `$lock`, `$brwsr`, etc.) at the top of hyprland.conf centralize which binary each keybind launches — change the variable, not each `bind` line, when swapping an app.
- **hyprlock** ([hypr/hyprlock.conf](hypr/hyprlock.conf)) is the lock screen, invoked via `pidof hyprlock || hyprlock` (idempotent — never launches a second instance).
- **Waybar** ([waybar/config.jsonc](waybar/config.jsonc), [waybar/style.css](waybar/style.css)) is the status bar. Custom modules shell out to scripts in the same directory:
  - `custom/night-mode` → [waybar/night-mode.sh](waybar/night-mode.sh) (renders icon/tooltip/class) and [waybar/night-mode-toggle.sh](waybar/night-mode-toggle.sh) (flips it, called both from Waybar's `on-click` and from the `$mainMod, N` keybind). Both scripts talk to `hyprsunset` over its IPC (`hyprctl hyprsunset temperature`), which is the single source of truth — there is no state file, so the two entry points cannot disagree. The toggle retunes the running daemon in place (day 6000K / night 3400K) and signals Waybar (`SIGRTMIN+10`, wired via the module's `"signal": 10`) to refresh immediately. `hyprsunset` itself runs as a systemd unit, so the toggle must never `pkill`/re-spawn it.
  - `custom/gpu` → [waybar/gpuinfo.sh](waybar/gpuinfo.sh); `custom/power` → [waybar/power-menu.sh](waybar/power-menu.sh).
- **rofi** ([rofi/config.rasi](rofi/config.rasi)) is the app launcher (`$menu`) and also backs the clipboard picker (`cliphist list | rofi -dmenu | cliphist decode | wl-copy`, bound to `$mainMod, V`).
- **swaync** ([swaync/config.json](swaync/config.json), [swaync/style.css](swaync/style.css)) is the notification daemon.
- **superfile** ([superfile/config.toml](superfile/config.toml), [superfile/hotkeys.toml](superfile/hotkeys.toml), `superfile/theme/*.toml`) is a TUI file manager (`spf`), launched via `$fileManager = alacritty -e spf`. The `theme/` directory holds many vendored color-scheme options; only one is active per `config.toml`'s `theme` key.
- **Alacritty** ([alacritty/alacritty.toml](alacritty/alacritty.toml)) is the canonical system terminal: it is `$alt-terminal`, backs `$fileManager` (`alacritty -e spf`), is what Nemo's "Open in Terminal" launches, and is the target of Waybar click-actions. `$terminal` (`warp-terminal`, `$mainMod, Q`) is the interactive daily driver but is deliberately not wired into system integration points. When changing the system terminal, update both the hyprland.conf `$`-vars and the Nemo gsetting below.
- **Nemo** is `$guiFileManager` (`$mainMod, B`). Two integration points live *outside* this repo, in untracked state, so they aren't obvious from the tracked files: its "Open in Terminal" target is `org.cinnamon.desktop.default-applications.terminal` `exec`/`exec-arg` in dconf (set to `alacritty -e`), and archive Compress/Extract requires the `nemo-fileroller` extension plus `file-roller` registered as the default handler for archive MIME types in the (gitignored) `mimeapps.list`. If those regress, check `gsettings get ...terminal exec` and `xdg-mime query default application/zip`, not a config file here.
- **systemd user units** back the long-running per-user daemons of the graphical session: [systemd/user/hyprsunset.service](systemd/user/hyprsunset.service) (blue-light filter), the package-provided `hypridle.service` (enabled, not stored here), and [systemd/user/hyprland-session.target](systemd/user/hyprland-session.target) (the session anchor). [systemd/user/hyprpolkitagent.service.d/override.conf](systemd/user/hyprpolkitagent.service.d/override.conf) tweaks the polkit agent. A unit that is `WantedBy=`/`PartOf=` a target must not also `Requires=` it (systemd.special(7)) — that inverts the dependency; use `PartOf` + `After`.
- **themes/Sweet-Custom** is a large vendored GTK/Cinnamon theme (its own `package.json`/`Gulpfile.js`/SCSS build is upstream scaffolding, not something this repo builds — `node_modules` is untracked). GTK resolves it via `~/.themes/Sweet-Custom` and `~/.local/share/themes/Sweet-Custom`, which are **symlinks into `~/.config/themes/Sweet-Custom`** (GTK does not search `~/.config/themes`); leave those symlinks in place. **Theming is driven by standards, not env overrides** — see the next section. When editing theme colors, note the cyberpunk customization lives in the SCSS sources (`gtk-3.0/_colors.scss`, `widgets/*.scss`) AND is baked into the committed compiled CSS (`gtk-3.0/gtk.css`, `gtk-dark.css`); a hand edit to one without the other will drift, and a full SCSS rebuild would overwrite manual CSS edits.

### Theming model (GTK + Qt)

Theming flows through the standard mechanisms; **do not** re-introduce the old `env = GTK_THEME,...` override in hyprland.conf (it defeats the portal and only reaches Hyprland-spawned apps), nor `GSETTINGS_SCHEMA_DIR` (redundant, shadows app schemas), nor `GTK2_RC_FILES` (hyprland doesn't expand `~`, so it exported a dead literal path).

- **GTK 3/4**: `gsettings` keys under `org.gnome.desktop.interface` (theme `Sweet-Custom`, icons `Sweet-Purple`, cursor `Adwaita`/24, `color-scheme prefer-dark`) plus `~/.config/gtk-{3,4}.0/settings.ini`. `xdg-desktop-portal` (portals.conf, `Settings` impl = hyprland, fallback gtk) exposes these to sandboxed and non-Hyprland-launched apps alike. Keep gsettings and both `settings.ini` files in sync.
- **GTK 2**: `~/.gtkrc-2.0` (read by default; no env var needed).
- **Qt**: `env = QT_QPA_PLATFORMTHEME,qt6ct` in hyprland.conf → `qt6ct` applies the `Fusion` style + the hand-built `~/.config/qt6ct/colors/Sweet-Custom.conf` palette. `kvantum`/`kvantum-qt5` are installed for SVG Qt theming if needed. (`qt5ct` is untracked; Qt5 apps fall back to `kvantum-qt5`.)
- `hyprsysteminfo` (a QML app) is launched directly by `$mainMod, I`; there is no theming wrapper script anymore.

A cyberpunk color palette (`#161925` background, `#5de5ff` cyan, `#d946ef` magenta/pink, `#c7f5ff` light cyan, `#b456f0` purple) recurs across Hyprland border colors, Alacritty's color scheme, and the wallpaper choice (`hypr/hyprpaper.conf` points at `Cyberpunk-3.jpeg`) — keep new theming consistent with it unless the user asks for a different look.

## Editing conventions

- Hyprland config uses `#` comments and `key = value` / `bind = MOD, KEY, ACTION, ARGS` syntax; consult the docs for keyword semantics before inventing new syntax. `wiki.hyprland.org` 301-redirects to `wiki.hypr.land`, and paths there have been restructured (e.g. `/Configuring/Dwindle-Layout/` moved to `/Configuring/Layouts/Dwindle-Layout/`) — the docs site is a JS-rendered SPA, so `curl`/WebFetch on a guessed path often 404s even when the page exists; find the real path from the rendered sidebar nav (in `<a href=...>` tags) first. Also note: as of Hyprland 0.55 the "latest" docs describe the new Lua config API by default — for this repo's legacy hyprlang `.conf` syntax, use the version-pinned docs linked from the page (e.g. `wiki.hypr.land/0.54.0/...`), since the option/dispatcher names between the two systems don't always match 1:1.
- Waybar config is JSONC (`.jsonc` — comments are allowed despite the `.json`-like content).
- Shell scripts under `waybar/` are plain bash; they must stay idempotent/race-safe since they're invoked both from Waybar's polling and from a Hyprland keybind concurrently. The night-mode scripts achieve this by holding no local state at all — they read/write the running `hyprsunset` daemon over IPC, so there's nothing to race on. When a value comes from an external command, guard it before arithmetic (`[[ "$x" =~ ^[0-9]+$ ]]`); several scripts here previously threw "integer expression expected" when a query returned empty.
- Keep `$variable` indirection in hyprland.conf for anything that names an application binary, rather than hardcoding the binary name in multiple `bind` lines.

## Applying changes (no build/test step — these are the closest equivalent)

- Hyprland: `hyprctl reload` re-reads hyprland.conf without restarting the session.
- Waybar: restart the process (e.g. `pkill waybar && waybar &`, or `killall -SIGUSR2 waybar` if supported) to pick up config/style/script changes.
- hypridle/hyprlock/hyprpaper: restart the individual process, or `hyprctl reload` where applicable.
- systemd user units: `systemctl --user daemon-reload && systemctl --user restart <unit>` after editing files under `systemd/user/`.

There is no linter, formatter, or automated test suite in this repo; validate changes by reloading the affected program and, where feasible, visually/functionally checking the result (this repo also has access to the `run` skill's general guidance about exercising a change before declaring it done — apply that spirit here by reloading/restarting the relevant daemon).

## Diagnosing Hyprland config errors

Don't rely on `hyprctl reload`'s own output (`ok`) as proof the config is valid — it doesn't surface parse errors. Instead:

- `hyprctl configerrors` (or `hyprctl -j configerrors` for JSON) lists every current config error with file and line number, e.g. `Config error in file .../hyprland.conf at line 179: config option <dwindle:pseudotile> does not exist.` This is the fastest way to find deprecated/removed options and dispatchers after a Hyprland upgrade — check it first, before grepping the config by hand.
- The live compositor log is at `/run/user/$UID/hypr/<instance-signature>/hyprland.log` (get the instance signature from `hyprctl instances` or by listing that directory). `grep -n "ERR \]" ` on it shows dispatcher/parse errors hit at startup (e.g. `Invalid dispatcher: togglesplit`), though `configerrors` is the more complete and current source of truth.
- To confirm a dispatcher name/args are valid without guessing from docs, test it live with `hyprctl dispatch <name> <args>` — but only for side-effect-free or easily-reversible dispatchers (e.g. `pseudo`, `layoutmsg togglesplit`). Never test `exit`, `killactive`, `exec`, or similar against the user's live session.
- To check whether a specific config option currently exists/what it's set to: `hyprctl -j getoption <category>:<name>` returns `"no such option"` if it's been removed.
- Cross-reference candidate replacement syntax against `strings $(which Hyprland) | grep -i <keyword>` — the binary's embedded option/dispatcher/error-message strings are a fast, version-exact way to confirm a name before trusting a docs page (which may describe a different Hyprland version, see above).
