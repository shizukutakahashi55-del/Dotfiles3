#!/usr/bin/env bash
# ============================================================
# waybar-theme-switcher.sh
# Cicla entre temas con cada llamada. Enlaza el script a un
# keybind en tu WM (Hyprland, i3, Sway, etc.)
#
# Uso:
#   waybar-theme-switcher.sh           → siguiente tema
#   waybar-theme-switcher.sh <nombre>  → tema específico
#
# Keybind Hyprland (en hyprland.conf):
#   bind = $mainMod, T, exec, ~/.config/waybar/themes/waybar-theme-switcher.sh
#
# Keybind i3/Sway (en config):
#   bindsym $mod+t exec ~/.config/waybar/themes/waybar-theme-switcher.sh
# ============================================================

THEMES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WAYBAR_CSS="$HOME/.config/waybar/style.css"
STATE_FILE="$HOME/.cache/waybar-current-theme"

# Lista de temas disponibles (nombre sin .css)
THEMES=(
    "catppuccin-mocha"
    "tokyo-night"
    "gruvbox"
    "rose-pine"
    "nord"
    "pastel-dream"
    "retro-terminal"
    "void-minimal"
    "neon-punk"
)

# ---------- funciones ----------

get_current_index() {
    if [[ -f "$STATE_FILE" ]]; then
        current=$(cat "$STATE_FILE")
        for i in "${!THEMES[@]}"; do
            [[ "${THEMES[$i]}" == "$current" ]] && echo "$i" && return
        done
    fi
    echo "0"
}

apply_theme() {
    local theme="$1"
    local css_file="$THEMES_DIR/${theme}.css"

    if [[ ! -f "$css_file" ]]; then
        echo "Error: no se encontró el tema '$theme' en $THEMES_DIR"
        exit 1
    fi

    # Copia el CSS al destino principal de waybar
    cp "$css_file" "$WAYBAR_CSS"

    # Guarda el estado actual
    echo "$theme" > "$STATE_FILE"

    # Reinicia waybar
    pkill -x waybar
    sleep 0.3
    waybar &>/dev/null &
    disown

    # Notificación opcional (requiere libnotify / dunst / mako)
    if command -v notify-send &>/dev/null; then
        notify-send -t 2000 -i preferences-desktop-theme \
            "Waybar Theme" "→  $theme"
    fi

    echo "Tema aplicado: $theme"
}

# ---------- lógica principal ----------

if [[ -n "$1" ]]; then
    # Modo: tema específico por nombre
    apply_theme "$1"
else
    # Modo: ciclar al siguiente
    current_index=$(get_current_index)
    next_index=$(( (current_index + 1) % ${#THEMES[@]} ))
    apply_theme "${THEMES[$next_index]}"
fi
