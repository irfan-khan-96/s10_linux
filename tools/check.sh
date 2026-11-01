#!/bin/bash
W=~/.local/var/pmbootstrap
echo "== install log tail"; tail -n 25 ~/s10-install.log 2>/dev/null
echo "== images"; ls -la $W/chroot_native/home/pmos/rootfs/ 2>/dev/null
echo "== boot files"; ls -la $W/chroot_rootfs_samsung-beyond1lte-downstream/boot/ 2>/dev/null
echo "== apks"; ls $W/packages/edge/aarch64/ 2>/dev/null | grep -iE 'beyond|firmware-samsung'
echo "== flasher help"; export PATH=$HOME/.local/bin:$PATH; pmbootstrap flasher --help </dev/null 2>&1 | sed -n '1,25p'
