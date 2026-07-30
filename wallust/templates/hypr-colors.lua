-- GENERATED FILE -- do not edit.
-- Rendered by wallust from ~/.config/wallust/colorschemes/<active>.json via
-- ~/.config/wallust/templates/hypr-colors.lua. Edit the template or the
-- colourscheme, then run ~/.config/wallust/theme-switch.
--
-- Consumed by hypr/looknfeel.lua (`require("theme/colors")`).

return {
    -- Two-stop gradient, magenta -> cyan at 45 degrees.
    active_border = {
        colors = {
            "rgba({{color1 | strip | lower}}ee)",
            "rgba({{color2 | strip | lower}}aa)",
        },
        angle = 45,
    },

    inactive_border = "rgba({{color4 | strip | lower}}aa)",

    -- Lua takes a packed ARGB integer here, not an rgba() string.
    shadow = 0xee{{color0 | strip | lower}},
}
