#!/bin/sh
# Run on the phone: display knobs for night mode / brightness, Wi-Fi quality, tmux mouse flags.
ls /sys/class/mdnie/mdnie/ 2>&1 | tr '\n' ' '; echo
for f in mode scenario night_mode accessibility bypass lux sensorRGB whiteRGB mdnie_ldu color_correct; do
	[ -e /sys/class/mdnie/mdnie/$f ] && echo "$f = $(cat /sys/class/mdnie/mdnie/$f 2>&1 | head -3 | tr '\n' ' ')"
done
cat /proc/net/wireless
tmux display -p 'client #{client_width}x#{client_height} pane #{pane_top},#{pane_left} mouse=#{mouse_any_flag} sgr=#{mouse_sgr_flag} alt=#{alternate_on}'
ls -l /tmp/tmux-*/ 2>&1
cat /sys/class/power_supply/battery/status
id
