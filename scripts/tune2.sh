#!/bin/sh
# Run the X server on the fast cores, then reboot for a clean Sxmo session.
# Run with: sudo sh ~/tune2.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
RC=/etc/X11/xinit/xserverrc
grep -q taskset $RC || sed -i 's|^exec /usr/bin/X |exec taskset -c 4-7 /usr/bin/X |' $RC
cat $RC
grep -q 'taskset -c 4-7' $RC || { echo "could not edit $RC"; exit 1; }
echo "== rebooting in 5 s for a clean Sxmo session (SSH back in ~3 min)"
sleep 5
reboot
