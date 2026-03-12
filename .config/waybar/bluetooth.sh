#!/usr/bin/env bash
# ============================================================
#   rofi-bluetooth — Bluetooth manager with Rofi
#   Dependencies: rofi, bluetoothctl, bluez
# ============================================================

ROFI_OPTS=(-dmenu -i -p "󰂯 Bluetooth" -theme ~/.config/waybar/bluetooth.rasi)

# ============================================================
#  HELPERS
# ============================================================

bt_power() {
    bluetoothctl show | grep -q "Powered: yes" && echo "on" || echo "off"
}

bt_toggle_power() {
    if [ "$(bt_power)" = "on" ]; then
        bluetoothctl power off
    else
        bluetoothctl power on
    fi
}

bt_scanning() {
    bluetoothctl show | grep -q "Discovering: yes" && echo "on" || echo "off"
}

# Return device list: "MAC | Name | status"
get_devices() {
    bluetoothctl devices | while read -r _ mac name; do
        info=$(bluetoothctl info "$mac" 2>/dev/null)
        connected=$(echo "$info" | grep -q "Connected: yes" && echo "yes" || echo "no")
        paired=$(echo "$info" | grep -q "Paired: yes" && echo "yes" || echo "no")

        if   [ "$connected" = "yes" ]; then status="󰂱 connected"
        elif [ "$paired" = "yes" ]; then status="󰂴 paired"
        else status="󰂲 available"
        fi

        echo "$mac|$name|$status"
    done
}

# ============================================================
#  MAIN MENU
# ============================================================

main_menu() {
    local power
    power=$(bt_power)

    local power_label scan_label

    if [ "$power" = "on" ]; then
        power_label="󰂯  Bluetooth: ON   ·  turn off"
    else
        power_label="󰂲  Bluetooth: OFF  ·  turn on"
    fi

    local options="$power_label"

    if [ "$power" = "on" ]; then

        if [ "$(bt_scanning)" = "on" ]; then
            scan_label="󰑐  Stop scanning"
        else
            scan_label="󰑐  Scan for devices"
        fi

        options="$options\n$scan_label"

        local devices
        devices=$(get_devices)

        if [ -n "$devices" ]; then
            options="$options\n─────────────────────"
            while IFS='|' read -r mac name status; do
                options="$options\n$status   $name"
            done <<< "$devices"
        fi
    fi

    options="$options\n─────────────────────\n  Exit"

    echo -e "$options"
}

# ============================================================
#  DEVICE MENU
# ============================================================

device_menu() {
    local mac="$1"
    local name="$2"

    local info
    info=$(bluetoothctl info "$mac" 2>/dev/null)

    local connected paired trusted
    connected=$(echo "$info" | grep -q "Connected: yes" && echo "yes" || echo "no")
    paired=$(echo "$info" | grep -q "Paired: yes" && echo "yes" || echo "no")
    trusted=$(echo "$info" | grep -q "Trusted: yes" && echo "yes" || echo "no")

    local opts=""

    [ "$connected" = "yes" ] \
        && opts="$opts\n󰂱  Disconnect" \
        || opts="$opts\n󰂴  Connect"

    [ "$paired" = "yes" ] \
        && opts="$opts\n󰌍  Forget device" \
        || opts="$opts\n󰌌  Pair device"

    [ "$trusted" = "yes" ] \
        && opts="$opts\n󰛅  Remove trust" \
        || opts="$opts\n󰛄  Trust device"

    opts="$opts\n─────────────────────\n  Back"

    local choice
    choice=$(echo -e "$opts" | rofi "${ROFI_OPTS[@]}" -p "  $name")

    case "$choice" in
        *"Connect")        bluetoothctl connect "$mac" ;;
        *"Disconnect")     bluetoothctl disconnect "$mac" ;;
        *"Pair"*)          bluetoothctl pair "$mac" ;;
        *"Forget"*)        bluetoothctl remove "$mac" ;;
        *"Trust device")   bluetoothctl trust "$mac" ;;
        *"Remove trust")   bluetoothctl untrust "$mac" ;;
        *"Back")           run_menu ;;
    esac
}

# ============================================================
#  MAIN LOOP
# ============================================================

run_menu() {
    local choice
    choice=$(main_menu | rofi "${ROFI_OPTS[@]}")

    [ -z "$choice" ] && exit 0

    case "$choice" in

        *"turn off"*|*"turn on"*)
            bt_toggle_power
            sleep 0.6
            run_menu
            ;;

        *"Scan for devices"*)
            bluetoothctl scan on &
            SCAN_PID=$!
            sleep 5
            kill $SCAN_PID 2>/dev/null
            bluetoothctl scan off
            run_menu
            ;;

        *"Stop scanning"*)
            bluetoothctl scan off
            run_menu
            ;;

        *"connected"*|*"paired"*|*"available"*)
            local dev_name
            dev_name=$(echo "$choice" | sed 's/.*   //')

            local mac
            mac=$(bluetoothctl devices | grep "$dev_name" | awk '{print $2}')

            [ -n "$mac" ] && device_menu "$mac" "$dev_name"
            ;;

        *"Exit"*|"")
            exit 0
            ;;

        *)
            run_menu
            ;;
    esac
}

# ============================================================
#  ENTRY POINT
# ============================================================

for dep in rofi bluetoothctl; do
    if ! command -v "$dep" &>/dev/null; then
        notify-send "rofi-bluetooth" "Missing dependency: $dep" -u critical
        exit 1
    fi
done

run_menu