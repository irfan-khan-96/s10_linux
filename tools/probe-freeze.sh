#!/bin/sh
# Run on the phone: every known way the screen has looked frozen, in one pass.
echo "console $(cat /sys/class/tty/tty0/active)  blanked $(cat /run/s10-blanked)  reserve $(cat /run/s10-osk-reserve)  rotate $(cat /run/s10-rotate 2>/dev/null || echo 0)"
echo "freezer $(cat /run/s10-freezer/paused/freezer.state 2>&1)  members: $(for p in $(cat /run/s10-freezer/paused/cgroup.procs 2>/dev/null); do cat /proc/$p/comm; done | tr '\n' ' ')"
echo "cpus online $(cat /sys/devices/system/cpu/online)  brightness $(cat /sys/class/backlight/panel/brightness)"
for p in s10-osk s10-idle-blank fbterm msm-fb-refresh; do
	for pid in $(pgrep -f "$p" | head -3); do
		echo "$(cat /proc/$pid/comm) pid $pid state $(awk '{print $3}' /proc/$pid/stat) wchan $(cat /proc/$pid/wchan)"
	done
done
tmux list-windows -F '#I:#W #{pane_current_command} mode=#{pane_in_mode} active=#{window_active}'
echo "--- osk.log"; tail -15 /tmp/osk.log
echo "--- recent panel messages"; dmesg | grep -E 'panel_fb_notifier|Display ON|decon_pan_display' | tail -4
