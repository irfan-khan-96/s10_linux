#!/bin/bash
R=~/.local/var/pmbootstrap/chroot_rootfs_samsung-beyond1lte-downstream
echo "== sshd"; find $R/usr $R/etc/init.d -name '*sshd*' -o -name 'dropbear*' 2>/dev/null | head
grep -E 'openssh|dropbear' $R/lib/apk/db/installed 2>/dev/null | head -5
echo "== /etc/wifi"; ls -la $R/etc/wifi 2>&1
echo "== firmware_class / cmdline"
grep -rhs 'firmware_class\|fw_path\|nvram' $R/etc/deviceinfo $R/usr/share/deviceinfo/* $R/etc/kernel/* $R/usr/lib/kernel/* 2>/dev/null | head
cat $R/usr/share/deviceinfo/deviceinfo 2>/dev/null | grep -i cmdline
ls $R/etc/kernel* $R/usr/lib/kernel 2>/dev/null
echo "== firmware conf"; grep -E '^CONFIG_(FW_LOADER|FIRMWARE_IN_KERNEL|EXTRA_FIRMWARE|BCMDHD_[A-Z_]*|DHD_[A-Z_]*|WLAN_REGION_CODE|BCMDHD_PCIE)=' ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/linux-samsung-beyond1lte-downstream/config-*.aarch64
