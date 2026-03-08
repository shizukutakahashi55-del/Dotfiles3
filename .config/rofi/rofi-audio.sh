#!/usr/bin/env bash
# ============================================================
#  rofi-audio.sh — rinooze
#  Control de audio con rofi + pipewire/pactl
# ============================================================
THEME="$HOME/.config/rofi/network.rasi"

get_sinks() {
    pactl list sinks | awk '
        /^Sink #/ { id=substr($2,2) }
        /Description:/ { desc=substr($0, index($0,$2)); print id"|"desc }
    '
}

get_sources() {
    pactl list sources | grep -v monitor | awk '
        /^Source #/ { id=substr($2,2) }
        /Description:/ { desc=substr($0, index($0,$2)); print id"|"desc }
    '
}

get_default_sink() {
    pactl get-default-sink
}

get_default_source() {
    pactl get-default-source
}

get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%'
}

get_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'
}

get_mic_mute() {
    pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}'
}

set_sink() {
    local sink_id="$1"
    pactl set-default-sink "$sink_id"
    # Mover streams activos al nuevo sink
    pactl list sink-inputs | awk '/^Sink Input #/{print substr($3,2)}' | while read -r input; do
        pactl move-sink-input "$input" "$sink_id"
    done
    notify-send "Audio" "🔊 Salida cambiada" --expire-time=2000
}

set_source() {
    local source_id="$1"
    pactl set-default-source "$source_id"
    notify-send "Audio" "🎙 Entrada cambiada" --expire-time=2000
}

# ── Menú principal ────────────────────────────────────────────
main_menu() {
    local vol=$(get_volume)
    local mute=$(get_mute)
    local mic_mute=$(get_mic_mute)

    local mute_label="󰖁 Mutear salida"
    [ "$mute" = "yes" ] && mute_label="󰕾 Desmutear salida"

    local mic_label="󰍭 Mutear micrófono"
    [ "$mic_mute" = "yes" ] && mic_label="󰍬 Desmutear micrófono"

    local options="󰕾 Volumen: ${vol}%\n󰔉 Subir volumen\n󰔉 Bajar volumen\n${mute_label}\n${mic_label}\n󰓃 Cambiar salida\n󰍬 Cambiar entrada (mic)"

    echo -e "$options" | rofi -dmenu \
        -p "Audio" \
        -i \
        -theme "$THEME"
}

# ── Menú salida ───────────────────────────────────────────────
sink_menu() {
    local default_sink=$(get_default_sink)
    local sinks=$(get_sinks)
    local options=""

    while IFS='|' read -r id desc; do
        local marker=""
        # Buscar si este sink es el default
        local sink_name=$(pactl list sinks | awk "/^Sink #${id}/{found=1} found && /Name:/{print \$2; exit}")
        [ "$sink_name" = "$default_sink" ] && marker=" ✓"
        options+="${desc}${marker}\n"
    done <<< "$sinks"

    local selected=$(echo -e "$options" | sed '/^$/d' | rofi -dmenu \
        -p "Salida de audio" \
        -i \
        -theme "$THEME"

    [ -z "$selected" ] && return

    local clean=$(echo "$selected" | sed 's/ ✓//')
    while IFS='|' read -r id desc; do
        if [ "$desc" = "$clean" ]; then
            set_sink "$id"
            break
        fi
    done <<< "$sinks"
}

# ── Menú entrada ──────────────────────────────────────────────
source_menu() {
    local default_source=$(get_default_source)
    local sources=$(get_sources)
    local options=""

    while IFS='|' read -r id desc; do
        local marker=""
        local source_name=$(pactl list sources | awk "/^Source #${id}/{found=1} found && /Name:/{print \$2; exit}")
        [ "$source_name" = "$default_source" ] && marker=" ✓"
        options+="${desc}${marker}\n"
    done <<< "$sources"

    local selected=$(echo -e "$options" | sed '/^$/d' | rofi -dmenu \
        -p "Entrada de audio (mic)" \
        -i \
        -theme "$THEME"

    [ -z "$selected" ] && return

    local clean=$(echo "$selected" | sed 's/ ✓//')
    while IFS='|' read -r id desc; do
        if [ "$desc" = "$clean" ]; then
            set_source "$id"
            break
        fi
    done <<< "$sources"
}

# ── Main ──────────────────────────────────────────────────────
selected=$(main_menu)
[ -z "$selected" ] && exit 0

case "$selected" in
    *"Subir volumen"*)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        notify-send "Audio" "🔊 Volumen: $(get_volume)%" --expire-time=1500
        ;;
    *"Bajar volumen"*)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        notify-send "Audio" "🔊 Volumen: $(get_volume)%" --expire-time=1500
        ;;
    *"Mutear salida"*)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        mute=$(get_mute)
        [ "$mute" = "yes" ] && notify-send "Audio" "🔇 Silenciado" --expire-time=1500 \
                             || notify-send "Audio" "🔊 Sonido activado" --expire-time=1500
        ;;
    *"Mutear micrófono"*)
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        mic=$(get_mic_mute)
        [ "$mic" = "yes" ] && notify-send "Audio" "🎙 Mic silenciado" --expire-time=1500 \
                            || notify-send "Audio" "🎙 Mic activado" --expire-time=1500
        ;;
    *"Cambiar salida"*)
        sink_menu
        ;;
    *"Cambiar entrada"*)
        source_menu
        ;;
esac
