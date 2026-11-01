#!/bin/sh
# Fix touch and colours under Sxmo on the S10. Run with: sudo sh ~/touchfix.sh
#  - sec_touchscreen registers Samsung's custom axis 0x3e with range [0,-1],
#    so libinput rejects the whole device; give that axis a valid range.
#  - the framebuffer runs at 16 bpp, so X must use depth 16, not 24.
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }

echo "== 1/4 touch axis fix helper"
mkdir -p /usr/local/bin
cat > /usr/local/bin/s10-touch-absfix <<'EOF'
#!/usr/bin/python3
# Give Samsung's unnamed axis 0x3e on sec_touchscreen a valid range (EVIOCSABS),
# because libinput rejects devices with an axis range of [0, -1].
import fcntl, glob, os, struct, sys
AXIS = 0x3e
def eviocsabs(axis):  # _IOW('E', 0xc0 + axis, struct input_absinfo) (6 x s32)
    return (1 << 30) | (24 << 16) | (ord("E") << 8) | (0xc0 + axis)
def eviocgabs(axis):  # _IOR('E', 0x40 + axis, struct input_absinfo)
    return (2 << 30) | (24 << 16) | (ord("E") << 8) | (0x40 + axis)
devs = sys.argv[1:] or glob.glob("/dev/input/event*")
for dev in devs:
    try:
        name = open(f"/sys/class/input/{os.path.basename(dev)}/device/name").read().strip()
    except OSError:
        continue
    if name != "sec_touchscreen":
        continue
    fd = os.open(dev, os.O_RDWR)
    buf = bytearray(24)
    fcntl.ioctl(fd, eviocgabs(AXIS), buf)
    value, lo, hi = struct.unpack_from("3i", buf)
    if hi < lo or hi == lo:
        fcntl.ioctl(fd, eviocsabs(AXIS), struct.pack("6i", value, 0, 1, 0, 0, 0))
        print(f"{dev}: axis 0x3e range [{lo}, {hi}] -> [0, 1]")
    else:
        print(f"{dev}: axis 0x3e already [{lo}, {hi}]")
    os.close(fd)
EOF
chmod 755 /usr/local/bin/s10-touch-absfix

echo "== 2/4 udev rule (runs the fix whenever the touchscreen appears, before X)"
mkdir -p /etc/udev/rules.d
cat > /etc/udev/rules.d/90-s10-touch-absfix.rules <<'EOF'
ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="sec_touchscreen", RUN+="/usr/local/bin/s10-touch-absfix /dev/%k"
EOF
udevadm control --reload
/usr/local/bin/s10-touch-absfix

echo "== 3/4 X at 16-bit colour to match the framebuffer"
sed -i 's/DefaultDepth 24/DefaultDepth 16/' /etc/X11/xorg.conf.d/10-s10-fbdev.conf
grep -q 'DefaultDepth 16' /etc/X11/xorg.conf.d/10-s10-fbdev.conf

echo "== 4/4 restarting Sxmo"
rc-service tinydm restart
sleep 15
grep -E "sec_touchscreen.*(rejected|Failed)|Depth|framebuffer bpp" /var/log/Xorg.0.log || true
grep -q "sec_touchscreen.*rejected" /var/log/Xorg.0.log && echo "TOUCH STILL REJECTED" || echo "touchscreen accepted by X"
echo "== done"
