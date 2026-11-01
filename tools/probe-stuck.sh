#!/bin/sh
# Run on the phone: processes in uninterruptible sleep (D), what they wait on, tmux and display state.
ps -o pid,stat,etime,args | awk '$2 ~ /D/'
for p in $(ps -o pid,stat | awk '$2 ~ /D/ {print $1}'); do echo "$p: $(cat /proc/$p/wchan 2>/dev/null)"; done
echo "--- tmux"; tmux list-windows -F '#I:#W #{pane_current_command} #{window_active}'
echo "--- display"; cat /sys/class/graphics/fb0/blank 2>&1; cat /run/s10-blanked; echo
pgrep -af 'fbterm|idle-blank|msm-fb'
