#!/bin/bash
set -e
cd ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/device-samsung-beyond1lte-downstream
if ! grep -q usb_network_function deviceinfo; then
cat >> deviceinfo <<'EOF'

# Samsung's downstream f_ncm never signals link-up to the host (carrier stays 0),
# so use RNDIS. Samsung's tethering IDs let Windows bind its RNDIS driver
# instead of the Android ADB driver that claims 18d1:d001.
deviceinfo_usb_network_function="rndis.usb0"
deviceinfo_usb_idVendor="0x04e8"
deviceinfo_usb_idProduct="0x6863"
EOF
fi
tail -7 deviceinfo
new=$(sha512sum deviceinfo | cut -d' ' -f1)
sed -i -E "s/^[0-9a-f]{128}  deviceinfo$/$new  deviceinfo/" APKBUILD
sed -i 's/^pkgrel=2$/pkgrel=3/' APKBUILD
grep -nE '^pkgrel' APKBUILD
git -c user.name="khan" -c user.email="khan@localhost" commit -qam "device-samsung-beyond1lte-downstream: use RNDIS with Samsung USB IDs"
git log --oneline -6
