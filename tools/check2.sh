#!/bin/bash
R=~/.local/var/pmbootstrap/chroot_rootfs_samsung-beyond1lte-downstream
for b in usr/bin/nmcli usr/bin/nmtui usr/sbin/wpa_supplicant usr/bin/iw usr/sbin/sshd usr/bin/htop; do
  [ -e "$R/$b" ] && echo "yes $b" || echo "NO  $b"
done
echo "== firmware"; ls $R/lib/firmware/postmarketos/ 2>/dev/null | head
echo "== wifi kernel config"; grep -E '^CONFIG_(BCMDHD|BCM4375|BROADCOM_WIFI|WLAN_VENDOR_BROADCOM|CFG80211)=' ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/linux-samsung-beyond1lte-downstream/config-*.aarch64
grep -E '^CONFIG_BCMDHD_(FW|NVRAM)_PATH' ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/linux-samsung-beyond1lte-downstream/config-*.aarch64
echo "== world"; cat $R/etc/apk/world 2>/dev/null
