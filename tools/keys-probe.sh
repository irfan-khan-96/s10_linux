#!/bin/sh
# Run on the phone: which input devices can send KEY_VOLUMEDOWN (114), plus recent osk log.
for d in /sys/class/input/event*; do
	caps=$(cat $d/device/capabilities/key)
	echo "$(basename $d) $(cat $d/device/name): key caps = $caps"
done
grep -n . /tmp/osk.log | tail -20
