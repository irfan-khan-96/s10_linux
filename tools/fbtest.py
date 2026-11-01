#!/usr/bin/env python3
# Draw colour bars on the S10 panel through mmap (the driver ignores write()),
# keeping /dev/fb0 open so the driver does not power the panel off.
# Run with: sudo python3 ~/fbtest.py
import fcntl, mmap, os, struct, time

FBIOGET_VSCREENINFO, FBIOGET_FSCREENINFO, FBIOPAN_DISPLAY, FBIOBLANK = 0x4600, 0x4602, 0x4606, 0x4611
fd = os.open("/dev/fb0", os.O_RDWR)
vinfo = bytearray(160); fcntl.ioctl(fd, FBIOGET_VSCREENINFO, vinfo)
finfo = bytearray(80);  fcntl.ioctl(fd, FBIOGET_FSCREENINFO, finfo)
xres, yres, xvirt, yvirt, xoff, yoff, bpp = struct.unpack_from("7I", vinfo, 0)
smem_len = struct.unpack_from("I", finfo, 24)[0]
line_length = struct.unpack_from("I", finfo, 48)[0]
print(f"{xres}x{yres} virtual {xvirt}x{yvirt} bpp={bpp} line_length={line_length} smem={smem_len}")

fcntl.ioctl(fd, FBIOBLANK, 0)                     # FB_BLANK_UNBLANK
fb = mmap.mmap(fd, smem_len, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE)
bpp_bytes = max(1, bpp // 8)
colours = [b"\xff\x00\x00\xff", b"\x00\xff\x00\xff", b"\x00\x00\xff\xff", b"\xff\xff\xff\xff"]
band = yres // len(colours)
for i, c in enumerate(colours):
    row = (c[:bpp_bytes] * xres).ljust(line_length, b"\0")
    for y in range(i * band, (i + 1) * band):
        fb[y * line_length:(y + 1) * line_length] = row
# pan to the first buffer so the controller pushes it to the panel
struct.pack_into("2I", vinfo, 16, 0, 0)
fcntl.ioctl(fd, FBIOPAN_DISPLAY, vinfo)
print("Colour bars drawn; keeping the screen on for 30 s ...")
time.sleep(30)
fb.close(); os.close(fd)
print("done (the driver will now switch the panel off again)")
