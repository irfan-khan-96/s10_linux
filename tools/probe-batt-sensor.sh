#!/bin/sh
# Run on the phone: battery charge-control knobs and the SSP sensor hub interface (read only).
B=/sys/class/power_supply/battery
ls $B | tr '\n' ' '; echo
for f in capacity status charge_type charge_control_end_threshold charge_control_limit batt_full_capacity store_mode batt_slate_mode batt_charging_source batt_temp; do
	[ -e $B/$f ] && echo "$f = $(cat $B/$f 2>&1)"
done
echo "--- sec battery knobs"; ls /sys/class/power_supply/
ls -l $B/ 2>/dev/null | grep -E '^-rw' | awk '{print $NF}' | tr '\n' ' '; echo
echo "--- ssp"; ls /sys/class/sensors/ssp_sensor/ | tr '\n' ' '; echo
cat /sys/class/sensors/ssp_sensor/enable 2>&1
ls /sys/class/sensors/accelerometer_sensor/ | tr '\n' ' '; echo
cat /sys/class/sensors/accelerometer_sensor/raw_data 2>&1
ls /sys/bus/iio/devices/iio:device1/scan_elements /sys/bus/iio/devices/iio:device33/scan_elements 2>&1 | tr '\n' ' '; echo
ls -l /dev/iio:device1 /dev/iio:device33
