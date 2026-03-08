#!/usr/bin/env bash
# ============================================================
#  wallpaper-rofi.sh — rinooze
#  Wallpaper picker usando rofi + hyprpaper
# ============================================================

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Seleccionar wallpaper con rofi
selected=$(ls "$WALLPAPER_DIR" | grep -iE '\.(jpg|jpeg|png|webp)$' | \
    rofi -dmenu \
        -p "Wallpaper" \
        -i \
        -theme-str '
            window { width: 600px; }
            listview { lines: 10; }
        ')

# Si no seleccionó nada, salir
[ -z "$selected" ] && exit 0

FULL_PATH="$WALLPAPER_DIR/$selected"

# Preload y aplicar en todos los monitores
hyprctl hyprpaper preload "$FULL_PATH"

for monitor in $(hyprctl monitors -j | python3 -c "import sys,json; [print(m['name']) for m in json.load(sys.stdin)]"); do
    hyprctl hyprpaper wallpaper "$monitor,$FULL_PATH"
done

# Actualizar hyprpaper.conf
CONF="$HOME/.config/hypr/hyprpaper.conf"
sed -i "s|^preload.*|preload = $FULL_PATH|" "$CONF"
sed -i "s|^wallpaper.*|wallpaper = ,$FULL_PATH|" "$CONF"

notify-send "Wallpaper" "✓ $selected aplicado" --icon="$FULL_PATH" 2>/dev/null || true

# Al final del script, después de aplicar el wallpaper
matugen image "$FULL_PATH"
