#!/bin/sh
# Run on the phone: show keyboard/terminal state.
apk list -I s10-terminal fbterm 2>/dev/null
pgrep -af s10-osk
echo "reserve: $(cat /run/s10-osk-reserve 2>&1)"
for p in $(pgrep -x fbterm); do
	echo "fbterm $p started $(ps -o etime= -p $p 2>/dev/null) ago, $(tr '\0' '\n' < /proc/$p/environ | grep FBTERM)"
done
tmux list-clients -F '#{client_width}x#{client_height}'
echo "--- osk.log"; cat /tmp/osk.log
