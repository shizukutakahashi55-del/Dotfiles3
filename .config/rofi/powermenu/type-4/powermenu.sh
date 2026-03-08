#!/usr/bin/env bash
## Power Menu - Catppuccin Mocha + SVG Icons

dir="$HOME/.config/rofi/powermenu/type-4"
icons="$dir/icons"
theme='style-5'

uptime="$(uptime -p | sed 's/up //g')"

# Opciones con path de icono usando sintaxis de rofi icon
shutdown="Shutdown\x00icon\x1f${icons}/shutdown.svg"
reboot="Reboot\x00icon\x1f${icons}/reboot.svg"
suspend="Suspend\x00icon\x1f${icons}/suspend.svg"
logout="Logout\x00icon\x1f${icons}/logout.svg"
hibernate="Hibernate\x00icon\x1f${icons}/hibernate.svg"

yes="Yes\x00icon\x1f${icons}/shutdown.svg"
no="No\x00icon\x1f${icons}/logout.svg"

# Rofi CMD principal
run_rofi() {
    printf "%b\n%b\n%b\n%b\n%b" \
        "$shutdown" "$reboot" "$suspend" "$logout" "$hibernate" | \
    rofi -dmenu \
        -p "  Goodbye ${USER}" \
        -mesg "󱑂  Uptime: $uptime" \
        -theme "${dir}/${theme}.rasi" \
        -show-icons \
        -markup-rows
}

# Confirmación
confirm_cmd() {
    printf "%b\n%b" "$yes" "$no" | \
    rofi -dmenu \
        -p "  Are you sure?" \
        -theme "${dir}/shared/confirm.rasi" \
        -show-icons \
        -markup-rows
}

run_cmd() {
    selected="$(confirm_cmd)"
    if [[ "$selected" == "Yes" ]]; then
        case $1 in
            --shutdown)  systemctl poweroff ;;
            --reboot)    systemctl reboot ;;
            --suspend)   systemctl suspend ;;
            --hibernate) systemctl hibernate ;;
            --logout)    hyprctl dispatch exit ;;
        esac
    else
        exit 0
    fi
}

# Main
chosen="$(run_rofi)"
case ${chosen} in
    "Shutdown")  run_cmd --shutdown ;;
    "Reboot")    run_cmd --reboot ;;
    "Suspend")   run_cmd --suspend ;;
    "Logout")    run_cmd --logout ;;
    "Hibernate") run_cmd --hibernate ;;
esac
