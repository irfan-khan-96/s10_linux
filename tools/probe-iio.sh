#!/bin/sh
# Run on the phone: list IIO sensors and sample any accelerometer three times.
for d in /sys/bus/iio/devices/iio:device*; do echo "$(basename $d) $(cat $d/name 2>/dev/null): $(ls $d | grep -c in_)"; done
for d in /sys/bus/iio/devices/iio:device*; do
	case "$(cat $d/name)" in *acc*|*ACC*) ls $d; for i in 1 2 3; do cat $d/in_accel_x_raw $d/in_accel_y_raw 2>&1 | tr '\n' ' '; echo; sleep 1; done;; esac
done
ls /dev/ssp* /sys/class/sensors 2>/dev/null | head -20
