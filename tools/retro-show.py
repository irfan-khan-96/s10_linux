#!/usr/bin/env python3
# Run on the phone as farmer (video group): show each mockup full-screen for a few seconds,
# then restore what was on the screen. Usage: retro-show.py <dir> <seconds> <name>...
import mmap, os, sys, time
import numpy as np
from PIL import Image

W, H = 1440, 3040
folder, seconds, names = sys.argv[1], float(sys.argv[2]), sys.argv[3:]
fd = os.open("/dev/fb0", os.O_RDWR)
fb = mmap.mmap(fd, W * H * 2, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE)
saved = fb[:]
try:
    for name in names:
        rgb = np.asarray(Image.open(f"{folder}/{name}.png").convert("RGB"), dtype=np.uint16)
        fb[:] = (((rgb[..., 0] >> 3) << 11) | ((rgb[..., 1] >> 2) << 5) | (rgb[..., 2] >> 3)).astype("<u2").tobytes()
        print("showing", name, flush=True)
        time.sleep(seconds)
finally:
    fb[:] = saved
    os.system("tmux refresh-client 2>/dev/null")
