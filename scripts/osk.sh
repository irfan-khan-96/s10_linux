#!/bin/sh
# On-screen keyboard (buffyboard) under the fbterm terminal, then reboot.
# Run with: sudo sh ~/osk.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
KB=1100                      # keyboard height in pixels (screen is 1440x3040)
TOP=$((3040 - KB))

echo "== 1/4 fbterm with the reserve-bottom patch, and buffyboard"
apk add -q --allow-untrusted /home/farmer/fbterm-1.7-r1.apk
apk add -q buffyboard
apk info -v 2>/dev/null | grep -E "^fbterm-1|^buffyboard-"

echo "== 2/4 keyboard look and behaviour"
cat > /etc/buffyboard.conf <<'EOF'
[keyboard]
haptic_feedback=true
sticky_shift=true

[theme]
default=adwaita-dark

[input]
pointer=false
touchscreen=true

[quirks]
fbdev_force_refresh=true
EOF

echo "== 3/4 start the keyboard at boot in the bottom ${KB} px"
cat > /etc/local.d/60-s10-osk.start <<EOF
#!/bin/sh
# buffyboard draws the keyboard in the strip fbterm leaves free (FBTERM_RESERVE_BOTTOM)
pidof buffyboard >/dev/null || setsid buffyboard -g 1440x${KB}@0,${TOP} -d 400 >/dev/null 2>&1 < /dev/null &
EOF
chmod 755 /etc/local.d/60-s10-osk.start

echo "== 4/4 rebooting in 5 s (terminal with keyboard in ~30 s)"
sleep 5
reboot
