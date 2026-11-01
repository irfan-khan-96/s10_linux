#!/bin/bash
set -e
SP=$(dirname "$0")
IMG=~/.local/var/pmbootstrap/chroot_native/home/pmos/rootfs/samsung-beyond1lte-downstream.img
T=/tmp/s10-imgcheck; mkdir -p $T
if [ "$(head -c 4 $IMG | xxd -p)" = "3aff26ed" ]; then
	python3 "$SP/unsparse.py" "$IMG" $T/raw.img >/dev/null; RAW=$T/raw.img
else
	RAW=$IMG
fi
off=$(python3 "$SP/gpt.py" "$RAW" | awk '/p2 /{for(i=1;i<=NF;i++) if ($i ~ /^offset=/) {sub("offset=","",$i); print $i}}')
size=$(python3 "$SP/gpt.py" "$RAW" | awk '/p2 /{for(i=1;i<=NF;i++) if ($i ~ /^size=/) {sub("size=","",$i); print $i}}')
dd if="$RAW" of=$T/root.ext4 bs=1M iflag=skip_bytes,count_bytes skip=$off count=$size status=none
DEBUGFS=$(command -v debugfs || echo /sbin/debugfs)
$DEBUGFS -R "ls -l /home/farmer/.ssh" $T/root.ext4 2>/dev/null
$DEBUGFS -R "cat /home/farmer/.ssh/authorized_keys" $T/root.ext4 2>/dev/null | cut -d' ' -f3
rm -rf $T
