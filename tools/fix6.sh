#!/bin/bash
set -e
cd ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/device-samsung-beyond1lte-downstream
python3 - <<'EOF'
p = "deviceinfo"; s = open(p).read()
old = ('# 512-byte sectors: on 4.14, losetup -P scans the partition table before\n'
       '# --sector-size is applied, so 4096-sector images show no subpartitions\n')
new = ('# MBR with 512-byte sectors (the pre-pmbootstrap-3.0 layout): the initramfs\n'
       '# counts subpartitions with busybox fdisk at the UFS 4096-byte sector size,\n'
       '# which only sees a 512-sector GPT as one protective entry, while 4.14\n'
       '# losetup -P scans before --sector-size applies, so 4096-sector GPT shows\n'
       '# no partitions. An MBR at byte 0 satisfies both.\n'
       'deviceinfo_partition_type="msdos"\n')
assert old in s or 'deviceinfo_partition_type' in s
s = s.replace(old, new); open(p, "w").write(s)
EOF
grep -n 'partition_type\|sector' deviceinfo
new=$(sha512sum deviceinfo | cut -d' ' -f1)
sed -i -E "s/^[0-9a-f]{128}  deviceinfo$/$new  deviceinfo/" APKBUILD
sed -i 's/^pkgrel=3$/pkgrel=4/' APKBUILD
grep -n '^pkgrel' APKBUILD
git -c user.name="khan" -c user.email="khan@localhost" commit -qam "device-samsung-beyond1lte-downstream: use msdos partition table"
git log -1 --oneline
