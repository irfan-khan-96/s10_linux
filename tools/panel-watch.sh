#!/bin/sh
# Run on the phone: for 5 minutes, print new display-related kernel messages as they appear.
seen=""
end=$(( $(date +%s) + 420 ))
while [ "$(date +%s)" -lt "$end" ]; do
	dmesg | grep -E 'dsim_(en|dis)able|decon_(en|dis)able|decon_blank|panel_sleep|panel_fb_notifier|Display ON|FRAME_DONE|panel_disable|panel_power' | while read -r line; do
		case "$seen" in *"$line"*) ;; *) echo "$line";; esac
	done > /tmp/pw.new
	if [ -s /tmp/pw.new ]; then cat /tmp/pw.new; seen="$seen$(cat /tmp/pw.new)"; fi
	sleep 0.5
done
