#!/bin/sh
# Run on the phone as root: test the battery limit knob, then sample the accelerometer
# for 20 s while the phone is turned. Restores the sensor hub's enable mask afterwards.
B=/sys/class/power_supply/battery
S=/sys/class/sensors
echo "--- panel: blank then unblank by hand"
dmesg -c >/dev/null
echo 1 > /sys/class/graphics/fb0/blank; sleep 1
echo 0 > /sys/class/graphics/fb0/blank; sleep 2
dmesg | grep -v -E 'pcie|dhd|wl_|CFG80211|dar_|BAR|AFTER_EP|D2H_MB|SysMMU|wlan_oob|Repeats|max77705' | tail -40
dmesg | grep -o 'lcd([0-9])' | tail -1
echo ">>> Is the screen on now? (answer in chat)"
echo "--- battery limit"
echo "before: batt_full_capacity=$(cat $B/batt_full_capacity)"
echo 85 > $B/batt_full_capacity && echo "after:  batt_full_capacity=$(cat $B/batt_full_capacity)"
dmesg | grep -i -E 'full_capacity|protect' | tail -3

echo "--- accelerometer"
old=$(cat $S/ssp_sensor/enable)
echo "enable mask was $old"
echo 1 > $S/ssp_sensor/enable 2>&1; echo "enable mask now $(cat $S/ssp_sensor/enable)"
cat /sys/bus/iio/devices/iio:device1/poll_delay 2>/dev/null
echo ">>> Turn the phone: portrait, left side down, upside down, right side down (5 s each)"
for i in $(seq 1 40); do
	printf '%5.1fs  %s\n' "$(echo "$i * 0.5" | bc)" "$(cat $S/accelerometer_sensor/raw_data 2>&1)"
	sleep 0.5
done
echo "$old" > $S/ssp_sensor/enable
echo "restored enable mask: $(cat $S/ssp_sensor/enable)"
dmesg | grep -i ssp | tail -5
