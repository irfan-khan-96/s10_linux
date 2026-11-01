#!/bin/sh
# Second touch fix for Sxmo on the S10. Run with: sudo sh ~/touchfix2.sh
#  - farmer needs the input/video/audio groups (Sxmo's gesture daemon reads
#    the touchscreen directly as farmer)
#  - a stable /dev/input/s10-touchscreen link for the gesture daemon
#  - restart X, then a 20-second live touch test
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }

echo "== 1/4 groups"
for g in input video audio; do addgroup farmer $g 2>/dev/null; done
id farmer

echo "== 2/4 touchscreen link"
cat > /etc/udev/rules.d/90-s10-touch-absfix.rules <<'EOF'
ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="sec_touchscreen", SYMLINK+="input/s10-touchscreen", RUN+="/usr/local/bin/s10-touch-absfix /dev/%k"
EOF
udevadm control --reload
udevadm trigger --action=change --subsystem-match=input
sleep 2
ls -l /dev/input/s10-touchscreen

echo "== 3/4 restarting Sxmo (screen goes black for ~20 s)"
rc-service tinydm stop >/dev/null 2>&1
pkill -x dwm; pkill -x lisgd; pkill -x xinit; pkill -x Xorg
sleep 3; pkill -9 -x Xorg 2>/dev/null
rm -f /tmp/.X0-lock /tmp/.X11-unix/X0
rc-service tinydm start >/dev/null
sleep 20
pgrep -a lisgd >/dev/null && echo "gesture daemon (lisgd): running" || echo "gesture daemon (lisgd): NOT running"

echo "== 4/4 live touch test: TAP AND SWIPE ON THE SCREEN NOW (20 seconds)"
export DISPLAY=:0 XAUTHORITY=$(ls -t /home/farmer/.serverauth.* | head -1)
ID=$(xinput list --id-only "pointer:sec_touchscreen" 2>/dev/null)
timeout 20 xinput test-xi2 --root "$ID" 2>/dev/null | grep -E "EVENT type|root:" | head -12
echo "(lines above = touches reaching X; none = touch input still not arriving)"
echo "== done"
