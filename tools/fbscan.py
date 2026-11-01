#!/usr/bin/env python3
# Where in video memory are non-black pixels? Rows grouped in 200-row bands.
import fcntl, mmap, os, struct
fd = os.open("/dev/fb0", os.O_RDONLY)
f = bytearray(80); fcntl.ioctl(fd, 0x4602, f)
smem = struct.unpack_from("I", f, 24)[0]; ll = struct.unpack_from("I", f, 48)[0]
m = mmap.mmap(fd, smem, mmap.MAP_SHARED, mmap.PROT_READ)
rows = smem // ll
for band in range(0, rows, 200):
    nz = 0
    for y in range(band, min(band + 200, rows), 10):
        line = m[y * ll:(y + 1) * ll]
        nz += len(line) - line.count(0)
    print(f"rows {band:5d}-{min(band+199, rows-1):5d}: {'#' * min(60, nz // 2000)} {nz}")
