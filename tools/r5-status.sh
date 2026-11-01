#!/bin/sh
# Run on the phone: r5 state (package, Syncthing gone, firewall, charge limit, idle-blank, wake).
apk list -I s10-terminal syncthing 2>/dev/null
ls /etc/init.d/s10-syncthing ~/.config/syncthing 2>&1 | sed 's/^/  /'
netstat -ltnu 2>/dev/null | grep -E ':22000|:21027' || echo "no Syncthing ports"
echo "charge limit: $(cat /sys/class/power_supply/battery/batt_full_capacity)"
pgrep -af 's10-idle-blank|s10-osk'
grep -c 'time.sleep(0.3)' /usr/bin/s10-idle-blank
echo "blanked: $(cat /run/s10-blanked)"
dmesg | grep -o 'lcd([0-9])' | tail -1
