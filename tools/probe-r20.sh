#!/bin/sh
# Run on the phone: r20 state (supervised services, update tool).
apk list -I s10-terminal 2>/dev/null
rc-update show default 2>/dev/null | grep -E 's10-|msm-fb'
rc-service s10-osk status 2>&1; rc-service s10-idle-blank status 2>&1
pgrep -af 'supervise-daemon|s10-osk|s10-idle-blank' | cut -c1-140
ls -l /usr/bin/s10-update /etc/local.d/*s10* 2>&1
echo "--- osk.log"; tail -5 /var/log/s10-osk.log
echo "--- idle-blank.log"; tail -5 /var/log/s10-idle-blank.log
ls /etc/*.apk-new /etc/*/*.apk-new 2>/dev/null
