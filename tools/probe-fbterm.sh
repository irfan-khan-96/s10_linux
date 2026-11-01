#!/bin/sh
# Run on the phone: is fbterm alive and reading its input?
p=$(pgrep -x fbterm)
grep -E 'State|SigQ|SigPnd|ShdPnd|SigBlk' /proc/$p/status
echo "wchan: $(cat /proc/$p/wchan)"
ls -l /proc/$p/fd/0 2>&1
cat /proc/$p/stat | cut -d' ' -f14,15
sleep 3
cat /proc/$p/stat | cut -d' ' -f14,15
ps -o pid,stat,etime,time,args | grep -E 'fbterm|tmux' | grep -v grep
