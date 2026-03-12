# ============================================================
#  .zshrc — rinooze
#  Catppuccin Mocha + Autocompletado + Historial + Fastfetch
# ============================================================

# ── Fastfetch al abrir terminal ──────────────────────────────
if command -v fastfetch &>/dev/null; then
    fastfetch
fi

# ── Historial ─────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# ── Opciones generales ────────────────────────────────────────
setopt AUTO_CD
setopt CORRECT
setopt EXTENDED_GLOB
setopt NO_BEEP

# ── Autocompletado ────────────────────────────────────────────
autoload -Uz compinit
compinit

setopt MENU_COMPLETE
setopt AUTO_LIST
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{#cba6f7}-- %d --%f'
zstyle ':completion:*:messages'     format '%F{#a6e3a1}-- %d --%f'
zstyle ':completion:*:warnings'     format '%F{#f38ba8}-- sin resultados --%f'
zstyle ':completion:*:corrections'  format '%F{#fab387}-- %d (errores: %e) --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' special-dirs true

# ── Plugins ───────────────────────────────────────────────────
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
fi

# ── Colores Catppuccin Mocha ──────────────────────────────────
CATT_MAUVE="%F{#cba6f7}"
CATT_RED="%F{#f38ba8}"
CATT_YELLOW="%F{#f9e2af}"
CATT_GREEN="%F{#a6e3a1}"
CATT_TEAL="%F{#94e2d5}"
CATT_SKY="%F{#89dceb}"
CATT_SAPPHIRE="%F{#74c7ec}"
CATT_BLUE="%F{#89b4fa}"
CATT_TEXT="%F{#cdd6f4}"
CATT_SUBTEXT="%F{#bac2de}"
CATT_OVERLAY="%F{#6c7086}"
RESET="%f"

# ── Autosuggestions ───────────────────────────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ── Syntax highlighting ───────────────────────────────────────
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[function]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#94e2d5'
ZSH_HIGHLIGHT_STYLES[path]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[string]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#fab387'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8,bold'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6c7086,italic'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#89dceb'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#89dceb'

# ── Prompt ────────────────────────────────────────────────────
autoload -Uz vcs_info
setopt PROMPT_SUBST

# Git: rama + estado dirty
zstyle ':vcs_info:*'      enable git
zstyle ':vcs_info:git:*'  check-for-changes true
zstyle ':vcs_info:git:*'  stagedstr     '%F{#a6e3a1}●%f'
zstyle ':vcs_info:git:*'  unstagedstr   '%F{#fab387}●%f'
zstyle ':vcs_info:git:*'  formats       ' %F{#cba6f7} %b%f%c%u'
zstyle ':vcs_info:git:*'  actionformats ' %F{#f38ba8} %b%f %F{#fab387}(%a)%f'

# Último exit code
_prompt_status() {
    local code=$?
    if [[ $code -ne 0 ]]; then
        echo " %F{#f38ba8}✘ ${code}%f"
    fi
}

# Tiempo de ejecución del último comando
_cmd_start_time=0
preexec() { _cmd_start_time=$SECONDS }

_cmd_elapsed() {
    local elapsed=$(( SECONDS - _cmd_start_time ))
    if (( elapsed >= 3 )); then
        if (( elapsed >= 60 )); then
            echo " %F{#6c7086}󱦟 $((elapsed/60))m$((elapsed%60))s%f"
        else
            echo " %F{#6c7086}󱦟 ${elapsed}s%f"
        fi
    fi
}

precmd() {
    vcs_info
    # Línea separadora sutil entre comandos
    print -P "%F{#313244}%f"
}

# Prompt multilinea:
# ╭─ 󰊠 user @ host  ~/path  branch ●
# ╰─ ❯
PROMPT='%F{#45475a}╭─%f %F{#cba6f7}󰊠%f %F{#89b4fa}%n%f%F{#6c7086}@%f%F{#74c7ec}%m%f  %F{#f9e2af}%~%f${vcs_info_msg_0_}$(_prompt_status)$(_cmd_elapsed)
%F{#45475a}╰─%f %(?.%F{#a6e3a1}.%F{#f38ba8})❯%f '

RPROMPT='%F{#45475a}%T%f'

# ── Keybindings ───────────────────────────────────────────────
bindkey -e
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^[[3~'   delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^R'      history-incremental-search-backward

# ── Aliases ───────────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias yi='yay -S'
alias yu='yay -Syu'

alias vi='nvim'
alias vim='nvim'
alias cls='clear'
alias reload='source ~/.zshrc'
alias zshconfig='nvim ~/.zshrc'

# cat → bat si está instalado
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain'
fi

# Hyprland
alias hyprconf='nvim ~/.config/hypr/hyprland.conf'
alias hyprlog='cat /tmp/hypr/$(ls /tmp/hypr/ | tail -1)/hyprland.log'

# Apps
alias nyx='~/Nyx-Python/start.sh'
alias freecad='QT_QPA_PLATFORM=xcb freecad'

# ── Variables de entorno ──────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export MANPAGER='less -R --use-color -Dd+r -Du+b'
export TERM='xterm-256color'
export PATH="$HOME/.local/bin:$PATH"

# ── LS_COLORS ─────────────────────────────────────────────────
export LS_COLORS="di=34:ln=36:so=35:pi=33:ex=32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
