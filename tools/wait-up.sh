#!/bin/bash
# Wait (up to 3 min) for the phone's SSH, then report touch and keyboard state.
for i in $(seq 36); do
	ssh -o ConnectTimeout=4 -o BatchMode=yes s10 true 2>/dev/null && break
	sleep 5
done
ssh s10 'echo "uptime $(cut -d" " -f1 /proc/uptime)s"
ls -l /dev/input/s10-touchscreen 2>&1
for d in /sys/class/input/event*; do printf "%s " "$(cat $d/device/name)"; done; echo
pgrep -af "s10-osk$" || echo "s10-osk NOT running"; tail -3 /tmp/osk.log
ls -l /var/log/dmesg*'
