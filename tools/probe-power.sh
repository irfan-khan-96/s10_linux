#!/bin/sh
# Run on the phone: battery state, current draw, what keeps the CPU busy, and sleep behaviour.
B=/sys/class/power_supply/battery
echo "uptime $(cut -d' ' -f1 /proc/uptime)s  capacity $(cat $B/capacity)%  status $(cat $B/status)"
echo "current_now $(cat $B/current_now) uA  current_avg $(cat $B/current_avg) uA  voltage $(cat $B/voltage_now)"
echo "--- suspend: state=$(cat /sys/power/state) mem_sleep=$(cat /sys/power/mem_sleep 2>&1) autosleep=$(cat /sys/power/autosleep 2>&1)"
echo "wakeup_count $(cat /sys/power/wakeup_count 2>&1)"
grep -E 'success|fail' /sys/kernel/debug/suspend_stats 2>/dev/null | head -3
echo "--- screen: blanked=$(cat /run/s10-blanked) brightness=$(cat /sys/class/backlight/panel/brightness)"
echo "--- cpu frequencies (kHz) and governors"
for p in /sys/devices/system/cpu/cpufreq/policy*; do
	echo "$(basename $p) cur=$(cat $p/scaling_cur_freq) min=$(cat $p/scaling_min_freq) gov=$(cat $p/scaling_governor)"
done
echo "--- top CPU users (ticks since boot)"
for d in /proc/[0-9]*; do
	set -- $(cat $d/stat 2>/dev/null | sed 's/([^)]*)/X/')
	[ -n "$14" ] && echo "$(( ${14} + ${15} )) $(cat $d/comm 2>/dev/null)"
done | sort -rn | head -12
echo "--- loadavg $(cat /proc/loadavg)"
echo "--- interrupts that tick a lot"
awk 'NR>1 {s=0; for (i=2;i<=9;i++) s+=$i; print s, $NF, $(NF-1)}' /proc/interrupts | sort -rn | head -8
echo "--- wakeup sources (active_count)"
sort -k2 -rn /sys/kernel/debug/wakeup_sources 2>/dev/null | head -8 || echo "(needs root)"
echo "--- radios"
nmcli radio 2>/dev/null; cat /sys/class/rfkill/*/soft 2>/dev/null | tr '\n' ' '; echo
