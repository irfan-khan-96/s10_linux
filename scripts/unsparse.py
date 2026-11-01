import struct, sys
src, dst = sys.argv[1], sys.argv[2]
f = open(src, "rb"); o = open(dst, "wb")
magic, maj, mnr, fhs, chs, bs, nblk, nch, _ = struct.unpack("<IHHHHIIII", f.read(28))
assert magic == 0xED26FF3A
f.seek(fhs)
for _ in range(nch):
    ctype, _, csz, tot = struct.unpack("<HHII", f.read(12)); f.seek(chs - 12, 1)
    data_len = tot - chs
    if ctype == 0xCAC1:   # raw
        o.write(f.read(data_len))
    elif ctype == 0xCAC2: # fill
        fill = f.read(4); o.write(fill * (csz * bs // 4))
    elif ctype == 0xCAC3: # don't care
        o.seek(csz * bs, 1)
    else:                 # crc
        f.seek(data_len, 1)
o.truncate(nblk * bs); print("unsparsed", nblk * bs, "bytes, block", bs)
