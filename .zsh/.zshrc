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

setopt HIST_IGNORE_DUPS       # No guardar duplicados consecutivos
setopt HIST_IGNORE_ALL_DUPS   # Borrar duplicados anteriores
setopt HIST_FIND_NO_DUPS      # No mostrar duplicados al buscar
setopt HIST_SAVE_NO_DUPS      # No guardar duplicados en archivo
setopt SHARE_HISTORY          # Compartir historial entre terminales
setopt APPEND_HISTORY         # Agregar al historial, no sobreescribir
setopt INC_APPEND_HISTORY     # Guardar al ejecutar, no al cerrar

# ── Opciones generales ────────────────────────────────────────
setopt AUTO_CD                # cd sin escribir 'cd'
setopt CORRECT                # Corrección de typos
setopt EXTENDED_GLOB          # Globbing extendido
setopt NO_BEEP                # Sin pitidos

# ── Autocompletado ────────────────────────────────────────────
autoload -Uz compinit
compinit

setopt MENU_COMPLETE          # Autocompletar directamente
setopt AUTO_LIST              # Listar opciones automáticamente
setopt COMPLETE_IN_WORD       # Completar dentro de palabras
setopt ALWAYS_TO_END          # Mover cursor al final al completar

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{#cba6f7}-- %d --%f'
zstyle ':completion:*:messages' format '%F{#a6e3a1}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{#f38ba8}-- sin resultados --%f'
zstyle ':completion:*:corrections' format '%F{#fab387}-- %d (errores: %e) --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' special-dirs true

# ── Plugins (via zsh nativo, sin oh-my-zsh) ───────────────────
# Autosuggestions (memoria de comandos)
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Syntax highlighting
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# History substring search (flechas para buscar en historial)
if [[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
fi

# ── Colores Catppuccin Mocha ──────────────────────────────────
# Palette
CATT_ROSEWATER="%F{#f5e0dc}"
CATT_FLAMINGO="%F{#f2cdcd}"
CATT_PINK="%F{#f5c2e7}"
CATT_MAUVE="%F{#cba6f7}"
CATT_RED="%F{#f38ba8}"
CATT_MAROON="%F{#eba0ac}"
CATT_PEACH="%F{#fab387}"
CATT_YELLOW="%F{#f9e2af}"
CATT_GREEN="%F{#a6e3a1}"
CATT_TEAL="%F{#94e2d5}"
CATT_SKY="%F{#89dceb}"
CATT_SAPPHIRE="%F{#74c7ec}"
CATT_BLUE="%F{#89b4fa}"
CATT_LAVENDER="%F{#b4befe}"
CATT_TEXT="%F{#cdd6f4}"
CATT_SUBTEXT="%F{#bac2de}"
CATT_OVERLAY="%F{#6c7086}"
RESET="%f"

# ── Autosuggestions — colores Catppuccin ─────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ── Syntax highlighting — colores Catppuccin ─────────────────
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

# ── Prompt (Catppuccin Mocha) ─────────────────────────────────
autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats "${CATT_MAUVE} %b${RESET}"
zstyle ':vcs_info:*' enable git

setopt PROMPT_SUBST

# Prompt: user@host dir branch ❯
PROMPT='${CATT_BLUE}%n${RESET}${CATT_OVERLAY}@${RESET}${CATT_SAPPHIRE}%m${RESET} ${CATT_YELLOW}%~${RESET}${vcs_info_msg_0_} ${CATT_MAUVE}❯${RESET} '

# Prompt de la derecha: hora
RPROMPT='${CATT_OVERLAY}%T${RESET}'

# ── Keybindings ───────────────────────────────────────────────
bindkey -e                          # Modo emacs (compatible con terminales)
bindkey '^[[H'  beginning-of-line   # Home
bindkey '^[[F'  end-of-line         # End
bindkey '^[[3~' delete-char         # Delete
bindkey '^[[1;5C' forward-word      # Ctrl+→
bindkey '^[[1;5D' backward-word     # Ctrl+←
bindkey '^R'    history-incremental-search-backward  # Ctrl+R buscar historial

# ── Aliases útiles ────────────────────────────────────────────
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
alias cat='bat --style=plain' 2>/dev/null || alias cat='cat'

alias cls='clear'
alias reload='source ~/.zshrc'
alias zshconfig='nvim ~/.zshrc'

# Hyprland
alias hyprconf='nvim ~/.config/hypr/hyprland.conf'
alias hyprlog='cat /tmp/hypr/$(ls /tmp/hypr/ | tail -1)/hyprland.log'

# ── Variables de entorno ──────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export MANPAGER='less -R --use-color -Dd+r -Du+b'
export TERM='xterm-256color'
export PATH="$HOME/.local/bin:$PATH"

# ── LS_COLORS (Catppuccin-like) ───────────────────────────────
export LS_COLORS="di=34:ln=36:so=35:pi=33:ex=32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
alias nyx="~/Nyx-Python/start.sh"
