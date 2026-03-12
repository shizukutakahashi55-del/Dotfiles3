#!/usr/bin/env bash

THEME="$HOME/.config/rofi/network.rasi"

# ------------------------------------------------
# Detect interfaces correctly
# ------------------------------------------------

wifi_device=$(nmcli -t -f DEVICE,TYPE dev | awk -F: '$2=="wifi"{print $1}')
eth_device=$(nmcli -t -f DEVICE,TYPE dev | awk -F: '$2=="ethernet"{print $1}')

wifi_status=$(nmcli -t -f GENERAL.STATE device show "$wifi_device" 2>/dev/null | cut -d: -f2)
eth_status=$(nmcli -t -f GENERAL.STATE device show "$eth_device" 2>/dev/null | cut -d: -f2)

wifi_ssid=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes"{print $2}')

# ------------------------------------------------
# Icons
# ------------------------------------------------

if [[ "$wifi_status" == "100 (connected)" ]]; then
    wifi_icon="󰤨"
    wifi_toggle="󰤭 Disable WiFi"
else
    wifi_icon="󰤯"
    wifi_toggle="󰤨 Enable WiFi"
fi

if [[ "$eth_status" == "100 (connected)" ]]; then
    eth_icon="󰈀"
    eth_display="Connected"
else
    eth_icon="󰈂"
    eth_display="Disconnected"
fi

# ------------------------------------------------
# WiFi display
# ------------------------------------------------

if [[ -n "$wifi_ssid" ]]; then
    wifi_display="$wifi_ssid"
else
    wifi_display="Disconnected"
fi

# ------------------------------------------------
# Menu
# ------------------------------------------------

options="${eth_icon} Ethernet: ${eth_display}\n${wifi_icon} WiFi: ${wifi_display}\n\n󰖩 Scan WiFi Networks\n${wifi_toggle}\n󰈀 Enable Ethernet\n󰗼 Disconnect All"

chosen=$(echo -e "$options" | rofi -dmenu -i \
    -p "󰁓 Network" \
    -theme "$THEME")

# ------------------------------------------------
# Actions
# ------------------------------------------------

case "$chosen" in

*"Scan WiFi Networks"*)

    networks=$(nmcli -t -f SSID,SIGNAL dev wifi list | \
        grep -v '^--' | \
        awk -F: '{printf "%s  (%s%%)\n",$1,$2}' | \
        sort -t'%' -k1 -nr)

    chosen_network=$(echo -e "$networks" | rofi -dmenu -i \
        -p "Select WiFi" \
        -theme "$THEME")

    chosen_network=$(echo "$chosen_network" | awk '{print $1}')

    if [ -n "$chosen_network" ]; then

        if nmcli con up "$chosen_network" 2>/dev/null; then
            notify-send "Connected" "$chosen_network"
        else

            password=$(rofi -dmenu -password \
                -p "Password for $chosen_network" \
                -theme "$THEME")

            if [ -n "$password" ]; then
                nmcli dev wifi connect "$chosen_network" password "$password"
            fi
        fi
    fi
;;

*"Disable WiFi"*)
    nmcli radio wifi off
;;

*"Enable WiFi"*)
    nmcli radio wifi on
;;

*"Enable Ethernet"*)
    nmcli device connect "$eth_device"
;;

*"Disconnect All"*)
    nmcli networking off
    sleep 1
    nmcli networking on
;;

esac