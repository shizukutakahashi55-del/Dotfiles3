#!/usr/bin/env bash
# Lista procesos conocidos de tray y permite matarlos con rofi

apps=(
    "Steam:steam"
    "Discord:discord"
    "Spotify:spotify"
)

options=""
for app in "${apps[@]}"; do
    name="${app%%:*}"
    proc="${app##*:}"
    if pgrep -f "$proc" > /dev/null; then
        options+="⏻  $name\n"
    fi
done

[ -z "$options" ] && notify-send "Tray" "No hay apps corriendo" && exit 0

selected=$(echo -e "$options" | rofi -dmenu -p "Cerrar app")
[ -z "$selected" ] && exit 0

name=$(echo "$selected" | sed 's/⏻  //')
for app in "${apps[@]}"; do
    if [[ "${app%%:*}" == "$name" ]]; then
        pkill -f "${app##*:}"
        notify-send "Tray" "✓ $name cerrado"
    fi
done
