#!/bin/sh
# Fully restart Sxmo/X so the touch fix and 16-bit depth take effect.
# Run with: sudo sh ~/restartx.sh
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
echo "== touch axis fix"
/usr/local/bin/s10-touch-absfix
echo "== stopping Sxmo and every X server"
rc-service tinydm stop >/dev/null 2>&1
pkill -x dwm; pkill -x xinit; pkill -x Xorg
sleep 3
pkill -9 -x Xorg 2>/dev/null
rm -f /tmp/.X0-lock /tmp/.X11-unix/X0
pgrep -a Xorg && echo "WARNING: X still running" || echo "no X running"
echo "== starting Sxmo"
rc-service tinydm start >/dev/null
sleep 20
pgrep -a Xorg
grep -E "FBDEV\(0\): Depth|sec_touchscreen.*(rejected|Using input driver)|axis range" /var/log/Xorg.0.log
grep -q "sec_touchscreen.*was rejected" /var/log/Xorg.0.log && echo "TOUCH STILL REJECTED" || echo "touchscreen accepted by X"
echo "== done"
