#!/bin/bash
set -e
W=~/.local/var/pmbootstrap
AP="/mnt/c/Users/irfan/Downloads/s10_firmware/SM-G973F_5_20230307174710_iv4idyztx6_fac/AP_G973FXXSGHWC2_CL25257816_QB62822408_REV01_user_low_ship_meta_OS12.tar.md5"
OUT=~/s10-odin
mkdir -p "$OUT"; cd "$OUT"; rm -f boot.img system.img vbmeta.img vbmeta.img.lz4 *.tar

# vbmeta from stock firmware, with verification disabled (flags=2, big-endian u32 at offset 120)
tar -xf "$AP" vbmeta.img.lz4
~/.venvs/s10tools/bin/python - <<'EOF'
import struct, subprocess, sys
try:
    import lz4.frame as f; data = f.decompress(open("vbmeta.img.lz4","rb").read())
except ImportError:
    data = subprocess.run(["lz4","-dc","vbmeta.img.lz4"], capture_output=True, check=True).stdout
assert data[:4] == b"AVB0", "not a vbmeta image"
old = struct.unpack(">I", data[120:124])[0]
data = data[:120] + struct.pack(">I", 2) + data[124:]
open("vbmeta.img","wb").write(data)
print(f"vbmeta: {len(data)} bytes, flags {old} -> 2")
EOF
rm -f vbmeta.img.lz4

magic=$(head -c 2 "$W/chroot_rootfs_samsung-beyond1lte-downstream/boot/initramfs" | xxd -p)
[ "$magic" = "1f8b" ] || { echo "ERROR: initramfs is not gzip (magic $magic) - rerun pmbootstrap install"; exit 1; }
echo "initramfs: gzip OK"
magic=$(head -c 2 "$W/chroot_rootfs_samsung-beyond1lte-downstream/boot/initramfs-extra" | xxd -p)
[ "$magic" = "1f8b" ] || { echo "ERROR: initramfs-extra is not gzip (magic $magic)"; exit 1; }
echo "initramfs-extra: gzip OK"
cp "$W/chroot_rootfs_samsung-beyond1lte-downstream/boot/boot.img" boot.img
cp "$W/chroot_native/home/pmos/rootfs/samsung-beyond1lte-downstream.img" system.img
SP=$(dirname "$0")
python3 "$SP/unsparse.py" system.img system.raw >/dev/null
gpt=$(python3 "$SP/gpt.py" system.raw); echo "$gpt"
echo "$gpt" | grep -q "MBR found: 2 partitions" \
  || { echo "ERROR: image does not have a 2-partition MBR table"; exit 1; }
rm -f system.raw
tar --format=ustar -cf pmos-s10-AP.tar boot.img system.img vbmeta.img
D=/mnt/c/Users/irfan/Downloads/s10_pmos; mkdir -p "$D"; cp pmos-s10-AP.tar "$D/"
tar -tvf "$D/pmos-s10-AP.tar"
ls -la "$D"
