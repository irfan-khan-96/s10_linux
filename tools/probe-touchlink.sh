#!/bin/sh
# Run on the phone: did the touchscreen driver come up this boot?
for d in /sys/class/input/event*; do echo "$(basename $d) $(cat $d/device/name)"; done
echo "--- sec_ts in kernel log (first and last lines)"
dmesg | grep -i 'sec_ts\|sec_input' | head -12
echo "..."
dmesg | grep -i 'sec_ts\|sec_input' | tail -6
ls /sys/bus/i2c/drivers/ | grep -i sec
ls /sys/bus/i2c/devices/4-0048 2>&1 | head
