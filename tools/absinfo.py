#!/usr/bin/env python3
import fcntl, os, struct
fd = os.open("/dev/input/s10-touchscreen", os.O_RDONLY)
names = {0x00: "ABS_X", 0x01: "ABS_Y", 0x2f: "MT_SLOT", 0x35: "MT_POSITION_X", 0x36: "MT_POSITION_Y", 0x39: "MT_TRACKING_ID", 0x30: "MT_TOUCH_MAJOR"}
for code, name in names.items():
    b = bytearray(24)
    fcntl.ioctl(fd, (2 << 30) | (24 << 16) | (ord("E") << 8) | (0x40 + code), b)
    value, lo, hi, fuzz, flat, res = struct.unpack("6i", b)
    print(f"{name:16} min={lo} max={hi} res={res}")
