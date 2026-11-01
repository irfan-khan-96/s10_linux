#!/bin/bash
# Screenshot the phone's framebuffer to a PNG (converted on the phone): shot.sh <out.png>
set -e
ssh s10 python3 - > "$1" <<'EOF'
import fcntl, io, mmap, os, struct, sys, numpy as np
from PIL import Image
fd = os.open("/dev/fb0", os.O_RDONLY)
v = bytearray(160); fcntl.ioctl(fd, 0x4600, v)
f = bytearray(80);  fcntl.ioctl(fd, 0x4602, f)
w, h, _, _, _, yoff, _ = struct.unpack_from("7I", v, 0)
smem = struct.unpack_from("I", f, 24)[0]; ll = struct.unpack_from("I", f, 48)[0]
m = mmap.mmap(fd, smem, mmap.MAP_SHARED, mmap.PROT_READ)
a = np.frombuffer(m[yoff * ll:(yoff + h) * ll], np.uint16).reshape(h, ll // 2)[:, :w]
rgb = np.dstack([((a >> 11) & 31) * 255 // 31, ((a >> 5) & 63) * 255 // 63, (a & 31) * 255 // 31])
buf = io.BytesIO(); Image.fromarray(rgb.astype(np.uint8)).resize((w // 3, h // 3)).save(buf, "PNG")
sys.stdout.buffer.write(buf.getvalue())
EOF
