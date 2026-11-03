#!/bin/bash
# Wait (up to 5 min) until the phone's screen goes off, give the saver 20 s, then probe it
# and count new display errors over the following 30 s.
for i in $(seq 60); do
	[ "$(ssh s10 cat /run/s10-blanked)" = 1 ] && break
	sleep 5
done
sleep 20
ssh s10 sh -s < /mnt/c/Users/irfan/Desktop/s10-postmarketos/tools/probe-saver.sh
a=$(ssh s10 'dmesg | grep -c decon_pan_display'); sleep 30; b=$(ssh s10 'dmesg | grep -c decon_pan_display')
echo "display errors in 30 s with screen off: $((b - a))"
