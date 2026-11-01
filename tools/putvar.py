#!/usr/bin/env python3
# Does FBIOPUT_VSCREENINFO (unchanged mode) make an earlier mmap stale?
import fcntl, mmap, os, struct, time
GETV, GETF, PUTV = 0x4600, 0x4602, 0x4601
ll, ystart, h = 2880, 2200, 300            # draw a band in the keyboard strip
fd = os.open("/dev/fb0", os.O_RDWR)
v = bytearray(160); fcntl.ioctl(fd, GETV, v)
f = bytearray(80); fcntl.ioctl(fd, GETF, f)
smem = struct.unpack_from("I", f, 24)[0]
print("smem_start before:", hex(struct.unpack_from("Q", f, 16)[0]))
old = mmap.mmap(fd, smem, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE)
fcntl.ioctl(fd, PUTV, v)                    # what LVGL does after mmap
f2 = bytearray(80); fcntl.ioctl(fd, GETF, f2)
print("smem_start after: ", hex(struct.unpack_from("Q", f2, 16)[0]))
band = b"\x1f\xf8" * 1440                   # magenta in RGB565
for y in range(ystart, ystart + h):
    old[y * ll:(y + 1) * ll] = band
fresh = mmap.mmap(fd, smem, mmap.MAP_SHARED, mmap.PROT_READ)
seen = fresh[(ystart + 10) * ll:(ystart + 11) * ll] == band
print("band drawn via OLD mapping visible in FRESH mapping:", seen)
time.sleep(5)
for y in range(ystart, ystart + h):
    old[y * ll:(y + 1) * ll] = b"\0" * ll
