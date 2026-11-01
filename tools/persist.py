#!/usr/bin/env python3
# Draw a band in the keyboard strip once, then watch whether it survives.
import mmap, os, time
ll, y0, h = 2880, 2200, 200
fd = os.open("/dev/fb0", os.O_RDWR)
fb = mmap.mmap(fd, ll * 3040, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE)
band = b"\xe0\x07" * 1440   # green in RGB565
for y in range(y0, y0 + h):
    fb[y * ll:(y + 1) * ll] = band
t0 = time.monotonic()
for t in (0, 0.1, 0.5, 1, 2, 4, 8):
    while time.monotonic() - t0 < t:
        time.sleep(0.01)
    rows = sum(fb[y * ll:(y + 1) * ll] == band for y in range(y0, y0 + h))
    print(f"t={t:4}s: {rows}/{h} rows still green")
