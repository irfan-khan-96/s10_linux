#!/bin/sh
# Run on the phone: show keyboard/terminal state.
apk list -I s10-terminal 2>/dev/null
ps -o pid,ppid,etime,args | grep -E 'apk|sudo|s10-osk' | grep -v grep
ls -l /run/s10-osk-hidden 2>&1
grep -c Visibility /usr/bin/s10-osk
echo "--- osk.log"; cat /tmp/osk.log
echo "--- fbterm"; pgrep -af fbterm
