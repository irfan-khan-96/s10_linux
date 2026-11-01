#!/bin/bash
set -e
cd ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/device-samsung-beyond1lte-downstream
python3 - <<'EOF'
p = "deviceinfo"; s = open(p).read()
old = 'deviceinfo_initfs_compression="gzip"\n'
new = old + ('# stage-1 extract_initramfs_extra() always runs "gzip -d", but mkinitfs\n'
             '# compresses initramfs-extra with zstd unless told otherwise\n'
             'deviceinfo_initfs_extra_compression="gzip"\n')
if "initfs_extra_compression" not in s:
    assert old in s; s = s.replace(old, new); open(p, "w").write(s)
EOF
grep -n 'compression' deviceinfo
new=$(sha512sum deviceinfo | cut -d' ' -f1)
sed -i -E "s/^[0-9a-f]{128}  deviceinfo$/$new  deviceinfo/" APKBUILD
sed -i 's/^pkgrel=4$/pkgrel=5/' APKBUILD
grep -n '^pkgrel' APKBUILD
git -c user.name="khan" -c user.email="khan@localhost" commit -qam "device-samsung-beyond1lte-downstream: gzip initramfs-extra"
git log -1 --oneline
