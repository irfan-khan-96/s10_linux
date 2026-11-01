#!/usr/bin/env python3
# Compare buffyboard's view of the framebuffer with a fresh mapping.
import fcntl, mmap, os, re, struct, subprocess
pid = subprocess.check_output(["pidof", "buffyboard"]).split()[0].decode()
maps = open(f"/proc/{pid}/maps").read()
m = re.search(r"^([0-9a-f]+)-([0-9a-f]+) rw-s .*dmabuf", maps, re.M)
start = int(m.group(1), 16)
ll, rows = 2880, 3040
def nonzero_rows(read_row):
    hits = [y for y in range(0, rows, 20) if any(read_row(y))]
    return f"{len(hits)} sampled rows non-black, range {hits[0] if hits else '-'}..{hits[-1] if hits else '-'}"
mem = open(f"/proc/{pid}/mem", "rb")
def bb_row(y):
    mem.seek(start + y * ll); return mem.read(ll)
fd = os.open("/dev/fb0", os.O_RDONLY)
fb = mmap.mmap(fd, ll * rows, mmap.MAP_SHARED, mmap.PROT_READ)
print("buffyboard mapping:", nonzero_rows(bb_row))
print("fresh mapping     :", nonzero_rows(lambda y: fb[y * ll:(y + 1) * ll]))
