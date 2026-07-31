# GENERATED FILE -- do not edit.
# Rendered by wallust from templates/palette.sh into wallust/generated/palette.sh.
#
# The active palette as shell variables, so scripts can read colours without
# parsing a colourscheme file. That matters because only CURATED palettes exist
# as JSON in colorschemes/ -- wallust's ~617 built-in themes have no file at
# all, so `jq` on colorschemes/<name>.json only works for half the themes.
#
# Meant to be `source`d:  . ~/.config/wallust/generated/palette.sh
# See the 16-colour mapping contract at the top of wallust.toml for what each
# slot means (C0 background, C2 primary accent, C1 magenta, C7 foreground, ...).

C0='{{color0 | lower}}'
C1='{{color1 | lower}}'
C2='{{color2 | lower}}'
C3='{{color3 | lower}}'
C4='{{color4 | lower}}'
C5='{{color5 | lower}}'
C6='{{color6 | lower}}'
C7='{{color7 | lower}}'
C8='{{color8 | lower}}'
C9='{{color9 | lower}}'
C10='{{color10 | lower}}'
C11='{{color11 | lower}}'
C12='{{color12 | lower}}'
C13='{{color13 | lower}}'
C14='{{color14 | lower}}'
C15='{{color15 | lower}}'

BACKGROUND='{{background | lower}}'
FOREGROUND='{{foreground | lower}}'
CURSOR='{{cursor | lower}}'
