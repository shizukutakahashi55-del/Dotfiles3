#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Launcher (Modi Drun, Run, File Browser, Window)
#
##  theme 3 modified, all credits to Aditya Shakya

dir="$HOME/.config/rofi/launchers/type-3"
theme='style-3'

## Run
rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi
