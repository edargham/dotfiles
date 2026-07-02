# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is `~/.config` on an Arch Linux (Hyprland/Wayland) desktop, tracked with git. There is no build system, no tests, and no application source code — every file here is a live configuration file consumed directly by the corresponding program. Editing a file in this repo changes the user's running desktop environment (after a reload/restart of the relevant program).

There is no README and no existing CLAUDE.md prior to this one.

## Repo scope and .gitignore

Only a subset of `~/.config` is tracked. [.gitignore](.gitignore) excludes machine-local, cache, or secret-bearing directories: `Code/`, `dconf/`, `glib-*/`, `gtk-*/`, `matplotlib/`, `pulse/`, `qalculate/`, `OpenRGB/`, `systemd/`, `vlc/`, `warp-terminal/`, `xfce4/`, `inkscape/`, `user-dirs.*`, `QtProject.conf`, `mimeapps.list`, `Kitware/CMakeSetup.conf`, `GIMP/`, `remmina/`, `freerdp/`.

Note `systemd/` is gitignored yet `systemd/user/*.service` files exist and are tracked — check `git status`/`git check-ignore` before assuming a path is excluded, since ignore rules and tracked state can diverge over time. When adding new config directories, check whether they contain machine-specific state (caches, history, tokens, hardware IDs) before `git add`-ing them; prefer ignoring those and committing only the human-authored settings files.

## Architecture: how the pieces fit together

This is a Hyprland (wlroots Wayland compositor) desktop. The pieces are wired together through [hypr/hyprland.conf](hypr/hyprland.conf), which is the entry point for the whole session:

- **Session startup** (`exec-once` lines in hyprland.conf) launches, in order: a terminal, polkit agent, dbus/systemd environment sync, xdg-desktop-portal restart, clipboard tooling (`wl-paste`/`cliphist`/`wl-clip-persist`), `swaync` (notifications), `xwaylandvideobridge`, `waybar`, `hyprpaper` (wallpaper), and `hypridle` (idle/lock daemon, configured via [hypr/hypridle.conf](hypr/hypridle.conf)).
- **Program variables** (`$terminal`, `$fileManager`, `$menu`, `$lock`, `$brwsr`, etc.) at the top of hyprland.conf centralize which binary each keybind launches — change the variable, not each `bind` line, when swapping an app.
- **hyprlock** ([hypr/hyprlock.conf](hypr/hyprlock.conf)) is the lock screen, invoked via `pidof hyprlock || hyprlock` (idempotent — never launches a second instance).
- **Waybar** ([waybar/config.jsonc](waybar/config.jsonc), [waybar/style.css](waybar/style.css)) is the status bar. Custom modules shell out to scripts in the same directory:
  - `custom/night-mode` → [waybar/night-mode.sh](waybar/night-mode.sh) (renders icon/tooltip/class by reading `hyprsunset`'s running temperature) and [waybar/night-mode-toggle.sh](waybar/night-mode-toggle.sh) (flips it, called both from Waybar's `on-click` and from the `$mainMod, N` Hyprland keybind — the two entry points share state via `waybar/.night-mode-state`, and the toggle script re-derives actual state from the running `hyprsunset` process rather than trusting the file blindly).
  - `custom/gpu` → [waybar/gpuinfo.sh](waybar/gpuinfo.sh); `custom/power` → [waybar/power-menu.sh](waybar/power-menu.sh).
- **rofi** ([rofi/config.rasi](rofi/config.rasi)) is the app launcher (`$menu`) and also backs the clipboard picker (`cliphist list | rofi -dmenu | cliphist decode | wl-copy`, bound to `$mainMod, V`).
- **swaync** ([swaync/config.json](swaync/config.json), [swaync/style.css](swaync/style.css)) is the notification daemon.
- **superfile** ([superfile/config.toml](superfile/config.toml), [superfile/hotkeys.toml](superfile/hotkeys.toml), `superfile/theme/*.toml`) is a TUI file manager (`spf`), launched via `$fileManager = alacritty -e spf`. The `theme/` directory holds many vendored color-scheme options; only one is active per `config.toml`'s `theme` key.
- **Alacritty** ([alacritty/alacritty.toml](alacritty/alacritty.toml)) is the primary/alt terminal.
- **systemd user units** (`systemd/user/hyprsunset.service`, `systemd/user/hyprpolkitagent.service.d/override.conf`) back long-running per-user daemons that Hyprland's `exec-once` starts/coordinates with.
- **themes/Sweet-Custom** is a large vendored GTK/Cinnamon theme (has its own `package.json`/`Gulpfile.js`/SCSS build — that build tooling is upstream project scaffolding, not something this repo builds). It's referenced by `env = GTK_THEME,Sweet-Custom:dark` in hyprland.conf and by `hypr/scripts/hyprsysteminfo-themed`, which exports `GTK_THEME`/`QT_STYLE_OVERRIDE`/`QT_QPA_PLATFORMTHEME` before launching `hyprsysteminfo` so that non-GTK-native tool picks up the theme.

A cyberpunk color palette (`#161925` background, `#5de5ff` cyan, `#d946ef` magenta/pink, `#c7f5ff` light cyan, `#b456f0` purple) recurs across Hyprland border colors, Alacritty's color scheme, and the wallpaper choice (`hypr/hyprpaper.conf` points at `Cyberpunk-3.jpeg`) — keep new theming consistent with it unless the user asks for a different look.

## Editing conventions

- Hyprland config uses `#` comments and `key = value` / `bind = MOD, KEY, ACTION, ARGS` syntax; consult the docs for keyword semantics before inventing new syntax. `wiki.hyprland.org` 301-redirects to `wiki.hypr.land`, and paths there have been restructured (e.g. `/Configuring/Dwindle-Layout/` moved to `/Configuring/Layouts/Dwindle-Layout/`) — the docs site is a JS-rendered SPA, so `curl`/WebFetch on a guessed path often 404s even when the page exists; find the real path from the rendered sidebar nav (in `<a href=...>` tags) first. Also note: as of Hyprland 0.55 the "latest" docs describe the new Lua config API by default — for this repo's legacy hyprlang `.conf` syntax, use the version-pinned docs linked from the page (e.g. `wiki.hypr.land/0.54.0/...`), since the option/dispatcher names between the two systems don't always match 1:1.
- Waybar config is JSONC (`.jsonc` — comments are allowed despite the `.json`-like content).
- Shell scripts under `waybar/` are plain bash; they must stay idempotent/race-safe since they're invoked both from Waybar's polling and from a Hyprland keybind concurrently (see the night-mode scripts' pattern of re-deriving state from the live process rather than trusting only the state file).
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
