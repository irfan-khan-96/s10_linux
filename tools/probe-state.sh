#!/bin/sh
# Run on the phone: package/Syncthing state, firewall, Bluetooth hardware, accelerometer.
apk list -I s10-terminal syncthing 2>/dev/null
rc-status default 2>/dev/null | grep -i sync
pgrep -a syncthing || echo "syncthing not running"
netstat -ltnu 2>/dev/null | grep -E ':22000|:21027|:8384' || echo "no syncthing ports open"
echo "--- bluetooth"; ls /sys/class/bluetooth 2>&1; ls /sys/class/rfkill 2>/dev/null | head
for r in /sys/class/rfkill/*; do echo "$(cat $r/type 2>/dev/null) $(cat $r/name 2>/dev/null) soft=$(cat $r/soft 2>/dev/null)"; done
command -v bluetoothctl hciattach btmgmt 2>/dev/null
ls /lib/firmware | grep -i -E 'bt|bcm|blue' | head
echo "--- sensors"; ls /sys/bus/iio/devices 2>&1 | head
