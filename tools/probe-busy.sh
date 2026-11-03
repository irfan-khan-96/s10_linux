#!/bin/sh
# Run on the phone: CPU use over 10 s per process, with the screen as it is now.
snap() { for d in /proc/[0-9]*; do read -r line < $d/stat 2>/dev/null || continue
	rest=${line#*) }; set -- $rest; echo "${d#/proc/} $(( ${12} + ${13} )) $(cat $d/comm 2>/dev/null)"; done; }
snap > /tmp/a; sleep 10; snap > /tmp/b
awk 'NR==FNR {a[$1]=$2; next} ($1 in a) && $2-a[$1] > 0 {printf "%5.1f%%  %s\n", ($2-a[$1]), $3}' /tmp/a /tmp/b | sort -rn | head -10
echo "cpus online: $(cat /sys/devices/system/cpu/online)"
iw dev wlan0 get power_save 2>&1
tmux list-windows -F '#I:#W #{pane_current_command}'
