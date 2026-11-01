#!/bin/bash
R=~/.local/var/pmbootstrap/chroot_rootfs_samsung-beyond1lte-downstream
echo "== mkinitfs version"; grep -A1 '^P:postmarketos-mkinitfs$\|^P:mkinitfs$' $R/lib/apk/db/installed | head -4
echo "== strings in mkinitfs about extra/compression"
strings $R/usr/sbin/mkinitfs 2>/dev/null | grep -iE 'initramfs-extra|initfs_extra|extra.*compress|compress.*extra|postprocess' | sort -u | head -20
echo "== postprocess users"
grep -rln 'mkinitfs_postprocess' $R/usr/ $R/etc/ 2>/dev/null | head
grep -rh 'mkinitfs_postprocess' ~/.local/var/pmbootstrap/cache_git/pmaports/device/*/*/deviceinfo | head -5
echo "== boot-deploy"; grep -n 'postprocess\|initramfs-extra' $R/usr/bin/boot-deploy* 2>/dev/null | head
