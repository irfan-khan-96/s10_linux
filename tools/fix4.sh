#!/bin/bash
set -e
cd ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/device-samsung-beyond1lte-downstream
python3 - <<'EOF'
p = "deviceinfo"; s = open(p).read()
old = 'deviceinfo_rootfs_image_sector_size="4096"\n'
new = ('# 512-byte sectors: on 4.14, losetup -P scans the partition table before\n'
       '# --sector-size is applied, so 4096-sector images show no subpartitions\n')
if old in s:
    s = s.replace(old, new); open(p, "w").write(s)
EOF
grep -n 'sector' deviceinfo || true
new=$(sha512sum deviceinfo | cut -d' ' -f1)
sed -i -E "s/^[0-9a-f]{128}  deviceinfo$/$new  deviceinfo/" APKBUILD
sed -i 's/^pkgrel=1$/pkgrel=2/' APKBUILD
grep -nE '^pkgrel|  deviceinfo$' APKBUILD
git -c user.name="khan" -c user.email="khan@localhost" commit -qam "device-samsung-beyond1lte-downstream: use 512-byte rootfs sectors (4.14 loop partscan)"
git log -1 --oneline
