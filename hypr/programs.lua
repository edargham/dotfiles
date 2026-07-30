-- The programs each keybind launches, in one place.
--
-- This replaces the old `$terminal = ...` hyprlang variables. Keep the
-- indirection: swap a value here rather than editing individual binds.
--
-- Note `alt_terminal` (alacritty) is the canonical *system* terminal -- it
-- backs file_manager, Nemo's "Open in Terminal", and waybar click-actions.
-- `terminal` (warp-terminal) is the interactive daily driver and is
-- deliberately NOT wired into system integration points.

return {
    terminal         = "warp-terminal",
    alt_terminal     = "alacritty",
    file_manager     = "alacritty -e spf",
    gui_file_manager = "nemo",
    menu             = "rofi -show drun",

    -- Idempotent: never launches a second lock instance.
    lock             = "pidof hyprlock || hyprlock",

    browser          = "librewolf",
    vscode           = "code",
    steam            = "steam",

    -- Quick capture straight to ~/Pictures/Screenshots (-z freezes the screen
    -- first so the selection does not chase moving content).
    shot             = "hyprshot -zm region",

    -- Capture then annotate. hyprshot -r writes raw PNG to stdout, satty reads
    -- it from '-'. --early-exit copy closes satty as soon as the result is on
    -- the clipboard; the file is still written via --output-filename, whose
    -- strftime specifiers satty expands itself.
    shot_annotate    = "hyprshot -zm region -r | satty --filename - "
                       .. "--output-filename '~/Pictures/Screenshots/satty-%Y%m%d-%H%M%S.png' "
                       .. "--copy-command wl-copy --early-exit copy --initial-tool arrow",

    -- Screen colour picker; -a copies straight to the clipboard. Genuinely
    -- useful for authoring new wallust palettes.
    picker           = "hyprpicker -a -f hex",
}
