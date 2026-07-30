# zsh interactive configuration.
#
# This file is tracked in ~/.config. It is found via ZDOTDIR, which is set by a
# two-line ~/.zshenv stub (that stub cannot live here -- zsh reads ~/.zshenv
# before it knows about ZDOTDIR).
#
# Ported from ~/.bashrc. Everything lives in .zshrc rather than .zprofile
# because terminals here spawn zsh as a NON-login interactive shell (alacritty
# does not pass -l), so .zprofile would never run. That also matches the old
# .bashrc, which returned early for non-interactive shells.

# ---------------------------------------------------------------- history ----
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY        # record timestamps
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE       # a leading space keeps a command out of history
setopt HIST_VERIFY             # expand !! but let me confirm before running
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY           # share across concurrent terminals

# ------------------------------------------------------------ shell opts ----
setopt AUTO_CD                 # `..` / a bare directory name cds
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

# ------------------------------------------------------------- completion ----
fpath=(/usr/share/zsh/site-functions $fpath)
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{cyan}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zcompcache"

# ------------------------------------------------------------ keybindings ----
bindkey -e                     # emacs bindings

# Up/Down search history for what has already been typed.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[[1;5C' forward-word     # ctrl-right
bindkey '^[[1;5D' backward-word    # ctrl-left
bindkey '^[[3~'   delete-char
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line

# ------------------------------------------------ environment (ex-bashrc) ----
# `typeset -U` keeps these arrays de-duplicated, so re-sourcing this file (or a
# nested shell) cannot stack up repeated PATH entries the way the old .bashrc
# could.
typeset -U path PATH fpath

# NVIDIA / Wayland
export WLR_NO_HARDWARE_CURSORS=1
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

# Gaming
export MANGOHUD=1
export PROTON_ENABLE_NVAPI=1
export PROTON_NO_ESYNC=1
export PROTON_USE_WINED3D=1

# CUDA.
#
# 12.4 is pinned AHEAD of the distro package on purpose -- do not "modernise"
# this. Arch's `cuda` package is 13.3.1 at /opt/cuda and /etc/profile.d/cuda.sh
# already appends /opt/cuda/bin, but /usr/local/cuda -> cuda-12.4 and the
# libtorch build in /usr/local/libtorch is built against 12.4. Prepending 12.4
# is what makes `nvcc` resolve to 12.4.131 instead of 13.x.
export CUDA_HOME=/usr/local/cuda-12.4
export CUDA_PATH=/usr/local/cuda-12.4
path=(/usr/local/cuda-12.4/bin $path)
export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH

# NOTE: the cuda-12.8 component below does not exist on disk
# (/usr/local/cuda-12.8/lib64/pkgconfig is absent) -- kept verbatim from the old
# .bashrc since a missing pkgconfig dir is harmless, but it can be dropped.
export PKG_CONFIG_PATH=/usr/lib64/pkgconfig:/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig:/usr/local/cuda-12.8/lib64/pkgconfig:$PKG_CONFIG_PATH

path=("$HOME/.local/bin" $path)

# Secrets are NOT kept in this file -- it is committed to a git remote. Put
# `export GH_TOKEN=...` and friends in ~/.config/secrets/env (chmod 600), which
# is gitignored. See the note in CLAUDE.md.
[[ -r "$HOME/.config/secrets/env" ]] && source "$HOME/.config/secrets/env"

# --------------------------------------------------------------- aliases ----
# eza replaces ls; keep `ls` muscle memory working.
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -l --group-directories-first --icons=auto --git'
    alias la='eza -la --group-directories-first --icons=auto --git'
    alias lt='eza --tree --level=2 --icons=auto'
else
    alias ls='ls --color=auto'
fi

alias grep='grep --color=auto'
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never' && alias less='bat'
command -v btop >/dev/null 2>&1 && alias top='btop'

# nvidia-smi used to run on EVERY interactive shell (~0.5s and a screenful of
# output). It is an alias now.
alias gpu='nvidia-smi'
alias gpuw='nvtop'

# Theme switcher (same script the SUPER+SHIFT+T keybind runs).
alias theme='~/.config/wallust/theme-switch'

# ------------------------------------------------------------------ tools ----
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

[[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -r /usr/share/fzf/completion.zsh   ]] && source /usr/share/fzf/completion.zsh

# Plugins. syntax-highlighting must be sourced LAST -- it wraps the ZLE widgets
# and will miss anything registered after it.
[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ----------------------------------------------------------------- prompt ----
# starship.toml is generated by wallust, so the prompt follows the active theme.
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ---------------------------------------------------------------- greeting ----
# fastfetch used to run on every interactive shell, including every subshell.
# SHLVL == 1 limits it to a freshly opened terminal.
if [[ -o interactive && ${SHLVL:-1} -eq 1 ]] && command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi
