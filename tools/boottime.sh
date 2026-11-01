#!/bin/sh
# Boot timeline from the kernel log: biggest gaps between consecutive messages.
echo "== milestones"
dmesg | grep -E "Freeing unused kernel|pmOS-rd|switch_root|Run .* as init|init: |random: crng init|EXT4-fs \(loop0p2\): mounted|udevd|decon-0 UNBLANK|wlan0: (associated|link becomes ready)|IPv6: ADDRCONF\(NETDEV_CHANGE\): wlan0|rndis0" | head -30
echo "== 15 largest gaps between kernel messages"
dmesg | sed -n 's/^\[ *\([0-9.]*\)\].*/\1 &/p' | awk '{t=$1; if (NR>1) printf "%8.2f s gap before [%s] %s\n", t-p, t, substr($0, index($0,$2)+0, 140); p=t}' | sort -rn | head -15
echo "== openrc log"
ls -la /var/log/rc.log 2>/dev/null && tail -40 /var/log/rc.log
grep -E "^rc_logger|^rc_parallel" /etc/rc.conf 2>/dev/null
echo "== uptime"; cat /proc/uptime
