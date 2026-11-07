#!/bin/sh
# Run on the phone as root: sudo sh sleep-test.sh  (it detaches, so the SSH session can close)
# Deep sleep test. Network traffic briefly holds a Wi-Fi wakeup source, which makes the kernel
# refuse a suspend ("write error"), so it retries. Each real sleep is ended either by the clock
# (after 60 s) or by something else; the wake reason shows whether Wi-Fi traffic (the PC pings
# the phone every 5 s) can wake it, which would keep SSH and Samba reachable while it sleeps.
# If the phone does not come back: hold Volume Down + Power (pin) for 7 s to force a restart.
log=/home/farmer/.cache/sleep-test.log
if [ "$1" != run ]; then
	: > "$log"
	setsid nohup sh "$0" run >/dev/null 2>&1 &
	echo "started; close this SSH window now (exit). Results in about 6 minutes in $log"
	exit 0
fi
say() { echo "$(date +%H:%M:%S) $*" >> "$log"; }
reason() { cat /sys/kernel/wakeup_reasons/last_resume_reason 2>/dev/null | tr '\n' ' '; }
sleep 20                                  # let the SSH session close
say "start; suspends ok=$(cat /sys/power/suspend_stats/success) failed=$(cat /sys/power/suspend_stats/fail)"
slept=0; tries=0
while [ $slept -lt 3 ] && [ $tries -lt 40 ]; do
	tries=$((tries + 1))
	t0=$(date +%s)
	if rtcwake -m mem -s 60 >/dev/null 2>&1; then
		dt=$(( $(date +%s) - t0 ))
		slept=$((slept + 1))
		say "try $tries: slept $dt s (60 = clock woke it); wake reason: $(reason)"
		sleep 8                           # stay up a moment: let Wi-Fi reconnect, show it answers
	else
		sleep 2
	fi
done
say "end: $slept sleeps in $tries tries; suspends ok=$(cat /sys/power/suspend_stats/success) failed=$(cat /sys/power/suspend_stats/fail)"
ping -c 2 -W 2 192.168.178.1 >/dev/null 2>&1 && say "wifi: router reachable" || say "wifi: router NOT reachable"
dmesg | grep -i -E "active wakeup source|wakeup_reason|PM: suspend|resume of|failed" | tail -30 >> "$log"
grep -i -E "host_wake|gpio_keys|rtc-alarm" /proc/interrupts >> "$log"
