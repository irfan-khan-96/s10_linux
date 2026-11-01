#!/bin/sh
# Run on the phone: sensor hub (SSP) status, readable without root.
S=/sys/class/sensors/ssp_sensor
for f in mcu_name mcu_rev sensor_state reset_info; do echo "$f = $(cat $S/$f 2>&1 | head -3)"; done
cat /sys/bus/iio/devices/iio:device1/scan_elements/in_timestamp_type 2>&1
cat /sys/bus/iio/devices/iio:device1/buffer/length /sys/bus/iio/devices/iio:device1/buffer/enable 2>&1
ls /lib/firmware | grep -i -E 'ssp|shub|chub|sensor|bbd|bcm4775'
dmesg | grep -i -E 'ssp|shub' | grep -v debug_work | tail -15
