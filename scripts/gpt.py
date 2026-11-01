import struct, sys
f = open(sys.argv[1], "rb")
mbr = f.read(512)
if mbr[510:512] == b"\x55\xaa":
    parts = [struct.unpack("<B3xBxxxII", mbr[446 + 16*i:462 + 16*i]) for i in range(4)]
    real = [(t, s, n) for _, t, s, n in parts if t not in (0, 0xEE)]
    if real:
        print(f"MBR found: {len(real)} partitions")
        for i, (t, s, n) in enumerate(real, 1):
            print(f"  p{i} type=0x{t:02x} offset={s*512} size={n*512}")
for ss in (512, 4096):
    f.seek(ss); h = f.read(92)
    if h[:8] != b"EFI PART":
        print(f"sector {ss}: no GPT header"); continue
    lba, n, esz = struct.unpack("<Q", h[72:80])[0], *struct.unpack("<II", h[80:88])
    f.seek(lba * ss); t = f.read(n * esz)
    print(f"sector {ss}: GPT found, entries at LBA {lba}")
    for i in range(n):
        e = t[i*esz:(i+1)*esz]
        if e[:16] == b"\0" * 16: continue
        first, last = struct.unpack("<QQ", e[32:48])
        print(f"  p{i+1} offset={first*ss} size={(last-first+1)*ss}")
