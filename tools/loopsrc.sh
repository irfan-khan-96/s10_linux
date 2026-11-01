#!/bin/bash
set -e
T=$(ls ~/.local/var/pmbootstrap/cache_distfiles/linux-samsung-beyond1lte-downstream-*.tar.gz | head -1)
echo "tarball: $T"
mkdir -p ~/s10-kernel && cd ~/s10-kernel
top=$(tar -tzf "$T" | head -1 | cut -d/ -f1)
tar -xzf "$T" "$top/drivers/block/loop.c"
cp "$top/drivers/block/loop.c" loop.c.orig
n=$(grep -n '^static void __loop_update_dio' loop.c.orig | cut -d: -f1)
sed -n "$n,$((n+40))p" loop.c.orig
echo "== util-linux or busybox losetup in initramfs?"
grep -rl 'direct-io' ~/.local/var/pmbootstrap/cache_git/pmaports/main/postmarketos-initramfs/ | head -3
grep -n 'losetup' ~/.local/var/pmbootstrap/cache_git/pmaports/main/postmarketos-initramfs/*.files ~/.local/var/pmbootstrap/cache_git/pmaports/main/postmarketos-initramfs/APKBUILD 2>/dev/null | head
