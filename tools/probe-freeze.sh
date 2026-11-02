#!/bin/sh
# Run on the phone: everything that has made the screen look frozen so far.
echo "console $(cat /sys/class/tty/tty0/active)  blanked $(cat /run/s10-blanked)  reserve $(cat /run/s10-osk-reserve)  rotate $(cat /run/s10-rotate 2>/dev/null || echo 0)"
echo "brightness $(cat /sys/class/backlight/panel/brightness)"
for p in s10-osk s10-idle-blank fbterm tmux; do
	for pid in $(pgrep -f "$p"); do
		echo "$p pid $pid state $(awk '{print $3}' /proc/$pid/stat) cpu $(awk '{print $14+$15}' /proc/$pid/stat) wchan $(cat /proc/$pid/wchan)"
	done
done
tmux list-windows -F '#I:#W #{pane_current_command} #{pane_in_mode} active=#{window_active}'
echo "--- osk.log"; tail -20 /tmp/osk.log
echo "--- dmesg"; dmesg | grep -v -E 'pcie|dhd|wl_|CFG80211|dar_|BAR|AFTER_EP|D2H_MB|SysMMU|wlan_oob|Repeats|max77705|Input Booster|sec_bat|SSP' | tail -12
