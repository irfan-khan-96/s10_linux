#!/bin/sh
# Run on the phone: is the screen-off power saver doing its job right now?
B=/sys/class/power_supply/battery
apk list -I s10-terminal iw 2>/dev/null
echo "screen blanked=$(cat /run/s10-blanked)  battery $(cat $B/capacity)% $(cat $B/status)  avg $(( $(cat $B/current_avg) / 1000 )) mA  now $(( $(cat $B/current_now) / 1000 )) mA"
echo "cpus online: $(cat /sys/devices/system/cpu/online)"
echo "freezer: $(cat /run/s10-freezer/paused/freezer.state 2>&1)  members: $(for p in $(cat /run/s10-freezer/paused/cgroup.procs 2>/dev/null); do cat /proc/$p/comm; done | tr '\n' ' ')"
iw dev wlan0 get power_save 2>&1
echo "input booster $(cat /sys/class/input_booster/enable_event 2>&1)  tmux status-interval $(tmux show -gv status-interval)"
echo "decon errors in kernel log: $(dmesg | grep -c decon_pan_display)"
echo "--- power log"; tail -5 /var/log/s10-power.log 2>&1
