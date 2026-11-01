#!/bin/sh
# Make the touch fix work at boot, add a Sxmo device profile, reboot.
# Run with: sudo sh ~/touchfix3.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }

echo "== 1/3 udev rule: pass the real device node (/dev/input/eventN)"
cat > /etc/udev/rules.d/90-s10-touch-absfix.rules <<'EOF'
ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="sec_touchscreen", SYMLINK+="input/s10-touchscreen", RUN+="/usr/local/bin/s10-touch-absfix $devnode"
EOF
udevadm control --reload
udevadm trigger --action=change --subsystem-match=input
sleep 2
/usr/local/bin/s10-touch-absfix /dev/input/s10-touchscreen

echo "== 2/3 Sxmo device profile for the Galaxy S10"
cat > /usr/bin/sxmo_deviceprofile_samsung,armv8.sh <<'EOF'
#!/bin/sh
# Galaxy S10 (samsung-beyond1lte-downstream), X11/dwm. Power and Bixby keys are broken.
export SXMO_TOUCHSCREEN_ID="sec_touchscreen"
EOF
chmod 755 /usr/bin/sxmo_deviceprofile_samsung,armv8.sh

echo "== 3/3 rebooting in 5 s (Sxmo and SSH back in ~3 min)"
sleep 5
reboot
