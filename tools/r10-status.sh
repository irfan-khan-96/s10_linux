#!/bin/sh
# Run on the phone: r10 state.
apk list -I s10-terminal 2>/dev/null
ls /etc/*.apk-new 2>/dev/null
pgrep -af 's10-osk|s10-idle-blank|fbterm' | cut -c1-120
echo "console $(cat /sys/class/tty/tty0/active)  rotate $(cat /run/s10-rotate 2>/dev/null || echo 0)  reserve $(cat /run/s10-osk-reserve)"
echo "brightness $(cat /sys/class/backlight/panel/brightness)  night_mode $(cat /sys/class/mdnie/mdnie/night_mode)  saved $(cat /var/lib/s10-terminal/brightness 2>&1)"
rc-update show boot 2>/dev/null | grep splash; ls -l /var/cache/s10-terminal/ 2>&1
echo "status: $(s10-status)"
tmux list-windows -F '#I:#W' | tr '\n' ' '; echo
echo "--- osk.log"; cat /tmp/osk.log
apk list -I fbterm 2>/dev/null
tmux display -p 'term=#{client_termname} features=#{client_termfeatures}'
tmux list-clients -F 'client #{client_width}x#{client_height}'
