
#!/usr/bin/env bash

# Obtener estado de las interfaces
wifi_status=$(nmcli -t -f DEVICE,STATE dev | grep "wifi" | cut -d: -f2)
ethernet_status=$(nmcli -t -f DEVICE,STATE dev | grep "ethernet" | cut -d: -f2)

# Crear lista de opciones iniciales
options="󰈀 Ethernet: $ethernet_status\n WiFi: $wifi_status\n---\n󰖩 Escanear Redes WiFi\n󰤭 Desactivar WiFi\n󰈁 Activar Ethernet"

chosen_option=$(echo -e "$options" | rofi -dmenu -i -p "Redes" -config ~/.config/rofi/config.rasi)

case "$chosen_option" in
    *"Escanear Redes WiFi"*)
        notify-send "Buscando redes WiFi..."
        networks=$(nmcli -t -f SSID dev wifi list | grep -v '^--' | sort -u)
        chosen_network=$(echo -e "$networks" | rofi -dmenu -i -p "Seleccionar WiFi:")
        
        if [ -n "$chosen_network" ]; then
            password=$(rofi -dmenu -p "Contraseña para $chosen_network" -password)
            if [ -n "$password" ]; then
                nmcli dev wifi connect "$chosen_network" password "$password" | xargs notify-send
            fi
        fi
        ;;
    *"Desactivar WiFi"*)
        nmcli radio wifi off && notify-send "WiFi Desactivado"
        ;;
    *"Activar Ethernet"*)
        nmcli device connect $(nmcli -t -f DEVICE dev | grep eth) && notify-send "Ethernet Conectado"
        ;;
    *)
        exit 0
        ;;
esac

