#!/bin/sh
# Run on the phone: recent backlight changes as the panel driver saw them.
echo "brightness now $(cat /sys/class/backlight/panel/brightness)  actual $(cat /sys/class/backlight/panel/actual_brightness)"
dmesg | grep -o 'panel_bl_set_brightness.*' | tail -15
