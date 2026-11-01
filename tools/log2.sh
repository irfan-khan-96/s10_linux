#!/bin/bash
L=~/.local/var/pmbootstrap/log.txt
sed -n '10985,10997p' "$L"; echo -----; sed -n '11066,11082p' "$L"; echo -----; sed -n '11318,11330p' "$L"
echo "== avbtool in native chroot?"; ls ~/.local/var/pmbootstrap/chroot_native/usr/bin | grep -i avb
echo "== avbtool pkg in pmaports?"; find ~/.local/var/pmbootstrap/cache_git/pmaports -maxdepth 3 -type d -name '*avb*'
