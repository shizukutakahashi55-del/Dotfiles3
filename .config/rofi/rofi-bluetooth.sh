#!/usr/bin/env bash
# ============================================================
#  rofi-bluetooth.sh — rinooze
#  Bluetooth control with rofi + bluetoothctl
# ============================================================
THEME="$HOME/.config/rofi/network.rasi"

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

# ── Main Menu ─────────────────────────────────────────────────
main_menu() {
    local power=$(bt_power)
    local power_label="󰂲 Bluetooth: OFF"
    [ "$power" = "yes" ] && power_label="󰂱 Bluetooth: ON"

    local options="${power_label}\n󰂴 Connected devices\n󰂰 Paired devices\n󰍷 Scan for new devices\n󰂲 Disconnect all"

    echo -e "$options" | rofi -dmenu \
        -p "Bluetooth" \
        -i \
        -theme "$THEME"
}

# ── Paired Devices Menu ───────────────────────────────────────
paired_menu() {
    local devices=$(paired_devices)
    local options=""

    while IFS='|' read -r mac name; do
        [ -z "$mac" ] && continue
        local connected=$(is_connected "$mac")
        local battery=$(device_battery "$mac")
        local marker=""
        [ "$connected" = "yes" ] && marker=" ✓ connected"
        [ -n "$battery" ] && marker="${marker} 󰁹${battery}"
        options+="${name}${marker}|${mac}\n"
    done <<< "$devices"

    [ -z "$options" ] && { notify-send "Bluetooth" "No paired devices found" --expire-time=2000; return; }

    local selected=$(echo -e "$options" | sed '/^$/d' | awk -F'|' '{print $1}' | rofi -dmenu \
        -p "Paired devices" \
        -i \
        -theme "$THEME")

    [ -z "$selected" ] && return

    local mac=$(echo -e "$options" | sed '/^$/d' | awk -F'|' -v sel="$selected" '$1==sel{print $2}')
    [ -z "$mac" ] && return

    local connected=$(is_connected "$mac")
    if [ "$connected" = "yes" ]; then
        device_action_menu "$mac" "$selected"
    else
        notify-send "Bluetooth" "🔗 Connecting to $selected..." --expire-time=2000
        bluetoothctl connect "$mac" && \
            notify-send "Bluetooth" "✓ Connected to $selected" --expire-time=2000 || \
            notify-send "Bluetooth" "✗ Connection error" --expire-time=2000
    fi
}

# ── Device Actions Menu ───────────────────────────────────────
device_action_menu() {
    local mac="$1"
    local name="$2"

    local action=$(echo -e "󰂱 Disconnect\n󰍷 Information\n󰚃 Forget device" | rofi -dmenu \
        -p "$name" \
        -i \
        -theme "$THEME")

    [ -z "$action" ] && return

    case "$action" in
        *"Disconnect"*)
            bluetoothctl disconnect "$mac"
            notify-send "Bluetooth" "󰂲 $name disconnected" --expire-time=2000
            ;;
        *"Information"*)
            local info=$(bluetoothctl info "$mac" | grep -E 'Name|Connected|Paired|Trusted|Battery' | sed 's/^\s*//')
            notify-send "Bluetooth — $name" "$info" --expire-time=5000
            ;;
        *"Forget"*)
            bluetoothctl remove "$mac"
            notify-send "Bluetooth" "🗑 $name removed" --expire-time=2000
            ;;
    esac
}

# ── Scan for New Devices ──────────────────────────────────────
scan_menu() {
    notify-send "Bluetooth" "󰍷 Scanning for 10 seconds..." --expire-time=3000
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
        echo "$paired" | grep -q "$mac" && continue  # skip already paired
        options+="${name} (${mac})|${mac}\n"
    done <<< "$devices"

    [ -z "$options" ] && { notify-send "Bluetooth" "No new devices found" --expire-time=2000; return; }

    local selected=$(echo -e "$options" | sed '/^$/d' | awk -F'|' '{print $1}' | rofi -dmenu \
        -p "New devices" \
        -i \
        -theme "$THEME")

    [ -z "$selected" ] && return

    local mac=$(echo -e "$options" | sed '/^$/d' | awk -F'|' -v sel="$selected" '$1==sel{print $2}')
    [ -z "$mac" ] && return

    notify-send "Bluetooth" "🔗 Pairing with $selected..." --expire-time=3000
    bluetoothctl pair "$mac" && \
        bluetoothctl trust "$mac" && \
        bluetoothctl connect "$mac" && \
        notify-send "Bluetooth" "✓ Connected to $selected" --expire-time=2000 || \
        notify-send "Bluetooth" "✗ Pairing error" --expire-time=2000
}

# ── Disconnect All ────────────────────────────────────────────
disconnect_all() {
    connected_devices | while read -r mac; do
        [ -z "$mac" ] && continue
        bluetoothctl disconnect "$mac"
    done
    notify-send "Bluetooth" "󰂲 All devices disconnected" --expire-time=2000
}

# ── Main ──────────────────────────────────────────────────────
selected=$(main_menu)
[ -z "$selected" ] && exit 0

case "$selected" in
    *"Bluetooth: ON"*|*"Bluetooth: OFF"*)
        power=$(bt_power)
        if [ "$power" = "yes" ]; then
            bluetoothctl power off
            notify-send "Bluetooth" "󰂲 Bluetooth off" --expire-time=2000
        else
            bluetoothctl power on
            notify-send "Bluetooth" "󰂱 Bluetooth on" --expire-time=2000
        fi
        ;;
    *"Connected devices"*)
        paired_menu
        ;;
    *"Paired devices"*)
        paired_menu
        ;;
    *"Scan"*)
        scan_menu
        ;;
    *"Disconnect all"*)
        disconnect_all
        ;;
esac