#!/bin/sh
# Run on the phone: show keyboard/terminal/launcher state.
apk list -I s10-terminal fbterm 2>/dev/null
ls /etc/*.apk-new 2>/dev/null
pgrep -af 's10-osk|s10-menu'
echo "reserve: $(cat /run/s10-osk-reserve 2>&1)"
for p in $(pgrep -x fbterm); do echo "fbterm pid $p"; done
grep -l Dell /sys/class/input/event*/device/name 2>/dev/null || echo "no USB keyboard"
tmux list-windows -F '#I:#W #{window_width}x#{window_height}'
tmux list-keys -T root M-m
