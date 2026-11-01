#!/bin/sh
# Replace the hand-installed setup with the s10-terminal package, then reboot.
# Run with: sudo sh ~/migrate.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
apk add --allow-untrusted /home/farmer/s10-terminal-1-r0.apk
apk info -e s10-terminal
# loose copies the package now provides in /usr/bin and /usr/lib/udev
rm -f /usr/local/bin/s10-osk /usr/local/bin/s10-idle-blank /usr/local/bin/s10-osk-start \
	/usr/local/bin/s10-touch-absfix /etc/udev/rules.d/90-s10-touch-absfix.rules
grep '^tty1' /etc/inittab
grep -l /usr/local/bin /etc/local.d/*.start && echo "WARNING: old paths left" || echo "boot scripts use /usr/bin"
echo "== rebooting in 5 s to test the packaged setup"
sleep 5
reboot
