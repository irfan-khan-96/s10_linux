#!/bin/bash
set -e
P=~/.local/var/pmbootstrap/cache_git/pmaports
echo "== how other downstream ports set it"
grep -h 'initfs_compression' $P/device/downstream/*/deviceinfo | sort | uniq -c | sort -rn | head -5
grep -n 'initfs_compression' $P/deviceinfo_schema.toml 2>/dev/null | head -3
cd $P/device/downstream/device-samsung-beyond1lte-downstream
grep -q '^deviceinfo_initfs_compression=' deviceinfo || \
  sed -i 's/^deviceinfo_create_initfs_extra="true"$/deviceinfo_create_initfs_extra="true"\n# 4.14 downstream kernel has no zstd initramfs support (only gzip\/lz4)\ndeviceinfo_initfs_compression="gzip"/' deviceinfo
tail -4 deviceinfo
new=$(sha512sum deviceinfo | cut -d' ' -f1)
sed -i -E "s/^[0-9a-f]{128}  deviceinfo$/$new  deviceinfo/" APKBUILD
sed -i 's/^pkgrel=0$/pkgrel=1/' APKBUILD
grep -nE '^pkgrel|  deviceinfo$' APKBUILD
git -c user.name="khan" -c user.email="khan@localhost" commit -qam "device-samsung-beyond1lte-downstream: use gzip initramfs (no zstd in 4.14)"
git log -1 --oneline
