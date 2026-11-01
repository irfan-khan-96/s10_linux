#!/usr/bin/env python3
# Dump the visible part of /dev/fb0 (mmap; the driver ignores read()) to stdout
# with a small header: width height bpp line_length yoffset
import fcntl, mmap, os, struct, sys
fd = os.open("/dev/fb0", os.O_RDONLY)
v = bytearray(160); fcntl.ioctl(fd, 0x4600, v)
f = bytearray(80);  fcntl.ioctl(fd, 0x4602, f)
xres, yres, _, _, xoff, yoff, bpp = struct.unpack_from("7I", v, 0)
smem = struct.unpack_from("I", f, 24)[0]; ll = struct.unpack_from("I", f, 48)[0]
m = mmap.mmap(fd, smem, mmap.MAP_SHARED, mmap.PROT_READ)
start = yoff * ll
out = sys.stdout.buffer
out.write(struct.pack("5I", xres, yres, bpp, ll, yoff))
out.write(m[start:start + yres * ll])
