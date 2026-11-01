#!/bin/sh
# Run buffyboard in verbose mode for 8 s and save its log.
# Run with: sudo sh ~/bbdiag.sh
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
pkill -x buffyboard; sleep 1
timeout 8 buffyboard -v -g 1440x1100@0,1940 -d 400 > /tmp/bb.log 2>&1
echo "exit=$?" >> /tmp/bb.log
chmod 644 /tmp/bb.log
# restart the normal instance
/etc/local.d/60-s10-osk.start
tail -40 /tmp/bb.log
