#!/bin/sh
# When did each OpenRC service start, in seconds after kernel start?
up=$(cut -d. -f1 /proc/uptime)
for f in /run/openrc/started/*; do
	s=$(basename "$f")
	# the started marker is a symlink created when the service finished starting
	t=$(stat -c %Y "$f" 2>/dev/null) || continue
	now=$(date +%s)
	echo "$((up - (now - t))) $s"
done | sort -n
echo "== runlevels"
for r in sysinit boot default; do printf "%s: " $r; ls /etc/runlevels/$r | tr '\n' ' '; echo; done
echo "== rc.conf"
grep -E "^rc_parallel|^rc_logger|^rc_depend_strict" /etc/rc.conf
