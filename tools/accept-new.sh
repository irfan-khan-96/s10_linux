#!/bin/sh
# Take the packaged versions of config files apk saved as *.apk-new, then start
# the keyboard and idle screen-off. Run with: sudo sh ~/accept-new.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
for f in $(find /etc -name "*.apk-new"); do
	mv -f "$f" "${f%.apk-new}"
	echo "updated ${f%.apk-new}"
done
grep -l /usr/local/bin /etc/local.d/*.start && echo "WARNING: old paths left" || echo "boot scripts use /usr/bin"
/etc/local.d/10-firewall.start
rc-service sshd reload >/dev/null
/usr/bin/s10-osk-start
sleep 3
ps -o pid,args | grep -E "[s]10-osk|[s]10-idle"
