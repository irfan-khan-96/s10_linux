import sys
src, dst, extra = sys.argv[1], sys.argv[2], sys.argv[3]
d = bytearray(open(src, "rb").read())
assert d[:8] == b"ANDROID!"
cmd = bytes(d[64:576]).rstrip(b"\0").decode()
# drop "quiet" so kernel/initramfs messages are visible
parts = [p for p in cmd.split() if p not in ("quiet", "splash")] + extra.split()
new = " ".join(dict.fromkeys(parts)).encode()
assert len(new) < 512, len(new)
d[64:576] = new.ljust(512, b"\0")
open(dst, "wb").write(d)
print("cmdline:", new.decode())
