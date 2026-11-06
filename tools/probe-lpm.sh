#!/bin/sh
# Run on the phone: did the charging-only boot reboot into a normal one, and is touch up?
apk list -I s10-terminal 2>/dev/null
echo "uptime $(cut -d' ' -f1 /proc/uptime)s"
grep -o 'androidboot.mode=[a-z]*' /proc/cmdline || echo "no androidboot.mode on this boot (normal)"
echo "lpm reboot stamp: $(cat /var/lib/s10-terminal/lpm-reboot 2>/dev/null || echo none)  ($(date -d @$(cat /var/lib/s10-terminal/lpm-reboot 2>/dev/null || echo 0) 2>/dev/null))"
ls -l /dev/input/s10-touchscreen 2>&1
pgrep -af 's10-osk$' || echo "s10-osk not running"
tail -3 /tmp/osk.log
