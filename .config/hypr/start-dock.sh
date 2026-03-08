#!/usr/bin/env bash
pkill -f nwg-dock-hyprland 2>/dev/null
sleep 0.3
nwg-dock-hyprland -p bottom -d -nolauncher
