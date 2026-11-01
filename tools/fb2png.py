import struct, sys, zlib
raw = open(sys.argv[1], "rb").read()
w, h, bpp, ll, yoff = struct.unpack_from("5I", raw, 0)
data = raw[20:]
scale = 3  # downscale for a viewable image
rows = []
for y in range(0, h, scale):
    line = data[y * ll:(y + 1) * ll]
    row = bytearray(b"\0")
    for x in range(0, w, scale):
        if bpp == 16:
            p = line[2 * x] | (line[2 * x + 1] << 8)
            r, g, b = (p >> 11) << 3, ((p >> 5) & 63) << 2, (p & 31) << 3
        else:
            b, g, r = line[4 * x], line[4 * x + 1], line[4 * x + 2]
        row += bytes((r, g, b))
    rows.append(bytes(row))
W, H = len(range(0, w, scale)), len(rows)
def chunk(t, d): return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(b"".join(rows), 6)) + chunk(b"IEND", b"")
open(sys.argv[2], "wb").write(png)
print(f"{w}x{h} {bpp}bpp yoff={yoff} -> {W}x{H} png")
