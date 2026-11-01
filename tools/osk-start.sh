#!/bin/sh
# (Re)start the idle screen-off daemon and the on-screen keyboard. Run as root.
# Exact patterns, so this script never matches itself.
pkill -f '^/usr/bin/python3 /usr/local/bin/s10-osk$'
pkill -f '^/usr/bin/python3 /usr/local/bin/s10-idle-blank$'
sleep 1
setsid /usr/local/bin/s10-idle-blank >/dev/null 2>&1 < /dev/null &
setsid /usr/local/bin/s10-osk > /tmp/osk.log 2>&1 < /dev/null &
