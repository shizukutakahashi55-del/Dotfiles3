#!/usr/bin/env bash
# ============================================================
#  rofi-bluetooth.sh — rinooze
#  Control de bluetooth con rofi + bluetoothctl
# ============================================================

# ── Helpers ───────────────────────────────────────────────────
bt_power() {
    bluetoothctl show | awk '/Powered:/{print $2}'
}

bt_scanning() {
    bluetoothctl show | awk '/Discovering:/{print $2}'
}

paired_devices() {
    bluetoothctl paired-devices | awk '{print $2"|"substr($0, index($0,$3))}'
}

connected_devices() {
    bluetoothctl devices Connected | awk '{print $2}'
}

is_connected() {
    local mac="$1"
    bluetoothctl info "$mac" | awk '/Connected:/{print $2}'
}

device_battery() {
    local mac="$1"
    bluetoothctl info "$mac" | awk '/Battery Percentage:/{gsub(/[()]/,"",$3); print $3"%"}' 2>/dev/null
}

# ── Menú principal ────────────────────────────────────────────
main_menu() {
    local power=$(bt_power)
    local power_label="󰂲 Bluetooth: OFF"
    [ "$power" = "yes" ] && power_label="󰂱 Bluetooth: ON"

    local options="${power_label}\n󰂴 Dispositivos conectados\n󰂰 Dispositivos emparejados\n󰍷 Escanear nuevos dispositivos\n󰂲 Desconectar todo"

    echo -e "$options" | rofi -dmenu \
        -p "Bluetooth" \
        -i \
        -theme-str 'window {width: 400px;} listview {lines: 6;}'
}

# ── Dispositivos emparejados ──────────────────────────────────
paired_menu() {
    local devices=$(paired_devices)
    local options=""

    while IFS='|' read -r mac name; do
        [ -z "$mac" ] && continue
        local connected=$(is_connected "$mac")
        local battery=$(device_battery "$mac")
        local marker=""
        [ "$connected" = "yes" ] && marker=" ✓ conectado"
        [ -n "$battery" ] && marker="${marker} 󰁹${battery}"
        options+="${name}${marker}|${mac}\n"
    done <<< "$devices"

    [ -z "$options" ] && { notify-send "Bluetooth" "No hay dispositivos emparejados" --expire-time=2000; return; }

    local selected=$(echo -e "$options" | sed '/^$/d' | awk -F'|' '{print $1}' | rofi -dmenu \
        -p "Dispositivos emparejados" \
        -i \
        -theme-str 'window {width: 500px;} listview {lines: 8;}')

    [ -z "$selected" ] && return

    local mac=$(echo -e "$options" | sed '/^$/d' | awk -F'|' -v sel="$selected" '$1==sel{print $2}')
    [ -z "$mac" ] && return

    local connected=$(is_connected "$mac")
    if [ "$connected" = "yes" ]; then
        device_action_menu "$mac" "$selected"
    else
        notify-send "Bluetooth" "🔗 Conectando a $selected..." --expire-time=2000
        bluetoothctl connect "$mac" && \
            notify-send "Bluetooth" "✓ Conectado a $selected" --expire-time=2000 || \
            notify-send "Bluetooth" "✗ Error al conectar" --expire-time=2000
    fi
}

# ── Acciones sobre dispositivo ────────────────────────────────
device_action_menu() {
    local mac="$1"
    local name="$2"

    local action=$(echo -e "󰂱 Desconectar\n󰍷 Información\n󰚃 Olvidar dispositivo" | rofi -dmenu \
        -p "$name" \
        -i \
        -theme-str 'window {width: 400px;} listview {lines: 4;}')

    [ -z "$action" ] && return

    case "$action" in
        *"Desconectar"*)
            bluetoothctl disconnect "$mac"
            notify-send "Bluetooth" "󰂲 $name desconectado" --expire-time=2000
            ;;
        *"Información"*)
            local info=$(bluetoothctl info "$mac" | grep -E 'Name|Connected|Paired|Trusted|Battery' | sed 's/^\s*//')
            notify-send "Bluetooth — $name" "$info" --expire-time=5000
            ;;
        *"Olvidar"*)
            bluetoothctl remove "$mac"
            notify-send "Bluetooth" "🗑 $name eliminado" --expire-time=2000
            ;;
    esac
}

# ── Escanear nuevos dispositivos ──────────────────────────────
scan_menu() {
    notify-send "Bluetooth" "󰍷 Escaneando 10 segundos..." --expire-time=3000
    bluetoothctl scan on &
    local scan_pid=$!
    sleep 10
    kill $scan_pid 2>/dev/null
    bluetoothctl scan off

    local devices=$(bluetoothctl devices | awk '{print $2"|"substr($0, index($0,$3))}')
    local paired=$(paired_devices | awk -F'|' '{print $1}')
    local options=""

    while IFS='|' read -r mac name; do
        [ -z "$mac" ] && continue
        echo "$paired" | grep -q "$mac" && continue  # saltar ya emparejados
        options+="${name} (${mac})|${mac}\n"
    done <<< "$devices"

    [ -z "$options" ] && { notify-send "Bluetooth" "No se encontraron dispositivos nuevos" --expire-time=2000; return; }

    local selected=$(echo -e "$options" | sed '/^$/d' | awk -F'|' '{print $1}' | rofi -dmenu \
        -p "Nuevos dispositivos" \
        -i \
        -theme-str 'window {width: 500px;} listview {lines: 8;}')

    [ -z "$selected" ] && return

    local mac=$(echo -e "$options" | sed '/^$/d' | awk -F'|' -v sel="$selected" '$1==sel{print $2}')
    [ -z "$mac" ] && return

    notify-send "Bluetooth" "🔗 Emparejando con $selected..." --expire-time=3000
    bluetoothctl pair "$mac" && \
        bluetoothctl trust "$mac" && \
        bluetoothctl connect "$mac" && \
        notify-send "Bluetooth" "✓ Conectado a $selected" --expire-time=2000 || \
        notify-send "Bluetooth" "✗ Error al emparejar" --expire-time=2000
}

# ── Desconectar todo ──────────────────────────────────────────
disconnect_all() {
    connected_devices | while read -r mac; do
        [ -z "$mac" ] && continue
        bluetoothctl disconnect "$mac"
    done
    notify-send "Bluetooth" "󰂲 Todos desconectados" --expire-time=2000
}

# ── Main ──────────────────────────────────────────────────────
selected=$(main_menu)
[ -z "$selected" ] && exit 0

case "$selected" in
    *"Bluetooth: ON"*|*"Bluetooth: OFF"*)
        power=$(bt_power)
        if [ "$power" = "yes" ]; then
            bluetoothctl power off
            notify-send "Bluetooth" "󰂲 Bluetooth apagado" --expire-time=2000
        else
            bluetoothctl power on
            notify-send "Bluetooth" "󰂱 Bluetooth encendido" --expire-time=2000
        fi
        ;;
    *"conectados"*)
        paired_menu
        ;;
    *"emparejados"*)
        paired_menu
        ;;
    *"Escanear"*)
        scan_menu
        ;;
    *"Desconectar todo"*)
        disconnect_all
        ;;
esac
