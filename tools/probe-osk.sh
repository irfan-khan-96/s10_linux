#!/bin/sh
# Run on the phone: on-screen keyboard state and recent touches.
echo "reserve: $(cat /run/s10-osk-reserve 2>&1)   blanked: $(cat /run/s10-blanked 2>&1)"
grep -H . /sys/class/input/event*/device/name | grep -i -E 'dell|s10-osk|touchscreen'
cat /proc/$(pgrep -f '^/usr/bin/python3 /usr/bin/s10-osk$')/status | grep -E 'State|VmRSS'
cat /var/log/s10-osk.log
echo "--- touches for 5 s (tap the screen keyboard now if you can):"
timeout 5 cat /dev/input/s10-touchscreen | od -An -tx1 | wc -l
