#!/usr/bin/env bash

STATE="$HOME/.cache/hyprpaper-last"
CONF="$HOME/.config/hypr/hyprpaper.conf"
DEFAULT="/home/rinooze/Pictures/Wallpapers/1024121.png"

# Si existe el cache lo usamos, si no, el default
[ -f "$STATE" ] && WALL=$(cat "$STATE") || WALL="$DEFAULT"

# Escribir la config limpia
printf "preload = %s\nwallpaper = ,%s\nsplash = false\nipc = on\n" "$WALL" "$WALL" > "$CONF"