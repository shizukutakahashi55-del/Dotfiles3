#!/usr/bin/env bash
# Network Manager Menu - Catppuccin Mocha

THEME="$HOME/.config/rofi/network.rasi"

# Obtener estado de las interfaces
wifi_status=$(nmcli -t -f DEVICE,STATE dev | grep "wifi" | cut -d: -f2)
ethernet_status=$(nmcli -t -f DEVICE,STATE dev | grep "ethernet" | cut -d: -f2)

# Íconos según estado
if [[ "$wifi_status" == "connected" ]]; then
    wifi_icon="󰤨"
    wifi_toggle="󰤭 Desactivar WiFi"
else
    wifi_icon="󰤯"
    wifi_toggle="󰤨 Activar WiFi"
fi

if [[ "$ethernet_status" == "connected" ]]; then
    eth_icon="󰈀"
else
    eth_icon="󰈂"
fi

# Opciones del menú
options="${eth_icon} Ethernet: ${ethernet_status}\n${wifi_icon} WiFi: ${wifi_status}\n\n󰖩 Escanear Redes WiFi\n${wifi_toggle}\n󰈀 Activar Ethernet\n󰗼 Desconectar Todo"

chosen_option=$(echo -e "$options" | rofi -dmenu -i \
    -p "󰁓 Red" \
    -theme "$THEME")

case "$chosen_option" in
    *"Escanear Redes WiFi"*)
        notify-send "󰖩 Buscando redes WiFi..." -t 2000
        networks=$(nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list | \
            grep -v '^--' | \
            awk -F: '{printf "%s  󰢾 %s%%\n", $1, $2}' | \
            sort -t'%' -k1 -rn | \
            awk '{print $1}' | \
            sort -u)

        chosen_network=$(echo -e "$networks" | rofi -dmenu -i \
            -p "󰤨 Seleccionar WiFi" \
            -theme "$THEME")

        if [ -n "$chosen_network" ]; then
            # Intentar conectar sin contraseña primero (redes guardadas)
            if nmcli con up "$chosen_network" 2>/dev/null; then
                notify-send "󰤨 Conectado" "$chosen_network" -t 3000
            else
                password=$(rofi -dmenu \
                    -p "󰢿 Contraseña para $chosen_network" \
                    -theme "$THEME" \
                    -password)
                if [ -n "$password" ]; then
                    result=$(nmcli dev wifi connect "$chosen_network" password "$password" 2>&1)
                    if echo "$result" | grep -q "successfully"; then
                        notify-send "󰤨 Conectado" "$chosen_network" -t 3000
                    else
                        notify-send "󰤭 Error" "No se pudo conectar a $chosen_network" -u critical -t 4000
                    fi
                fi
            fi
        fi
        ;;

    *"Desactivar WiFi"*)
        nmcli radio wifi off
        notify-send "󰤭 WiFi Desactivado" -t 2000
        ;;

    *"Activar WiFi"*)
        nmcli radio wifi on
        notify-send "󰤨 WiFi Activado" -t 2000
        ;;

    *"Activar Ethernet"*)
        device=$(nmcli -t -f DEVICE dev | grep eth | head -1)
        if [ -n "$device" ]; then
            nmcli device connect "$device"
            notify-send "󰈀 Ethernet Conectado" -t 2000
        else
            notify-send "󰈂 Error" "No se encontró interfaz ethernet" -u critical -t 3000
        fi
        ;;

    *"Desconectar Todo"*)
        nmcli networking off
        sleep 1
        nmcli networking on
        notify-send "󰗼 Red reiniciada" -t 2000
        ;;

    *)
        exit 0
        ;;
esac
