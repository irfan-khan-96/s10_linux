import struct, sys
d = open(sys.argv[1], "rb").read()
ks, ka, rs = struct.unpack("<3I", d[8:20]); ps = struct.unpack("<I", d[36:40])[0]
off = ps + ((ks + ps - 1) // ps) * ps
r = d[off:off + rs]
print("ramdisk size", rs, "magic", r[:4].hex(), "gzip" if r[:2] == b"\x1f\x8b" else "NOT gzip")
print("tail SEANDROIDENFORCE:", b"SEANDROIDENFORCE" in d[-4096:] or b"SEANDROIDENFORCE" in d)
