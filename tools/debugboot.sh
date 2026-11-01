#!/bin/bash
set -e
SP=$(dirname "$0")
P=~/.local/var/pmbootstrap/cache_git/pmaports
echo "== initramfs debug options in this pmOS version"
grep -rhoE 'pmos\.[a-z_-]+' $P/main/postmarketos-initramfs/ 2>/dev/null | sort -u | head -20
grep -rn 'debug-shell\|ttyGS0\|acm' $P/main/postmarketos-initramfs/*.sh 2>/dev/null | head -15
mkdir -p ~/s10-debug && cd ~/s10-debug
python3 "$SP/debugboot.py" ~/s10-odin/boot.img boot.img "pmos.debug-shell console=ttyGS0,115200 console=tty0"
tar --format=ustar -cf pmos-s10-debugboot-AP.tar boot.img
cp pmos-s10-debugboot-AP.tar /mnt/c/Users/irfan/Downloads/s10_pmos/
ls -la /mnt/c/Users/irfan/Downloads/s10_pmos/
