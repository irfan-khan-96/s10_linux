#!/bin/sh
# Run on the phone: landscape state.
apk list -I s10-terminal 2>/dev/null
echo "rotate: $(cat /run/s10-rotate 2>&1)  reserve: $(cat /run/s10-osk-reserve 2>&1)  console: $(cat /sys/class/tty/tty0/active)"
grep -l -i keyboard /sys/class/input/event*/device/name 2>/dev/null | xargs -r cat
for p in $(pgrep -x fbterm); do echo "fbterm $p: $(tr '\0' ' ' < /proc/$p/cmdline)"; done
tmux list-clients -F 'client #{client_width}x#{client_height}'
cat /tmp/osk.log
