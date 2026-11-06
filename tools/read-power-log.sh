#!/bin/sh
# Run on the phone: the on-battery part of the standby log, plus the battery right now.
grep -v -E 'Charging|Full' /var/log/s10-power.log
echo "--- now: uptime $(cut -d' ' -f1 /proc/uptime)s  $(cat /sys/class/power_supply/battery/capacity)% $(cat /sys/class/power_supply/battery/status)"
