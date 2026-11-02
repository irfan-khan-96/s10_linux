#!/bin/sh
# Run on the phone: when the splash, display and terminal came up during this boot.
boot=$(awk '/^btime/ {print $2}' /proc/stat)
f=/var/cache/s10-terminal/splash.rgb565
[ -e $f ] && echo "splash image rendered at $(( $(stat -c %Y $f) - boot ))s after boot ($(stat -c %s $f) bytes)"
for p in s10-osk fbterm; do
	pid=$(pgrep -f "$p" | head -1)
	[ -n "$pid" ] && echo "$p started at $(awk '{print $22/100}' /proc/$pid/stat)s"
done
