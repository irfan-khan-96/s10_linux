#!/bin/bash
# Build a fresh postmarketOS image from the fork (asks for the WSL sudo password and the new
# phone user's password), check it contains the whole setup, and export it.
set -e
OUT=/mnt/c/Users/irfan/Desktop/s10-postmarketos/images
cd ~/pmbootstrap
./pmbootstrap.py config extra_packages
./pmbootstrap.py build fbterm s10-terminal
./pmbootstrap.py install
echo "=== checking the image"
./pmbootstrap.py chroot -r -- sh -c '
	apk list -I s10-terminal fbterm 2>/dev/null
	apk list -I syncthing 2>/dev/null | grep . && echo "WARNING: syncthing present" || echo "no syncthing: ok"
	for f in /usr/bin/s10-menu /usr/bin/s10-osk /usr/bin/s10-idle-blank /etc/local.d/45-s10-battery.start /etc/init.d/unudhcpd.rndis0; do
		[ -e $f ] && echo "ok $f" || echo "MISSING $f"
	done
	grep -n "^tty1" /etc/inittab
	grep -c 22000 /etc/local.d/10-firewall.start || true'
# the SSH key goes straight into the image (mnt/install), not the rootfs chroot
grep -q 'mnt/install/home/.*/.ssh/authorized_keys' ~/.local/var/pmbootstrap/log.txt && echo "ok ssh key copied into image"
./pmbootstrap.py export
mkdir -p "$OUT"
cp -L /tmp/postmarketOS-export/boot.img /tmp/postmarketOS-export/samsung-beyond1lte-downstream.img "$OUT"/
ls -lh "$OUT"
