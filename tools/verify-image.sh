#!/bin/bash
# Run in WSL: which packages the last image build installed, the SSH key copy, exported files.
L=~/.local/var/pmbootstrap/log.txt
grep -o -E 'chroot_rootfs_samsung[^ ]* .*add .*' "$L" | tail -1 | grep -o -E '(s10-terminal|fbterm)-[0-9.]+-r[0-9]+' | sort -u
grep -E 'mnt/install/home/.*/.ssh/authorized_keys' "$L" | tail -1 | grep -o '\[[0-9:]*\]'
grep -E 'Export symlinks' "$L" | tail -1 | grep -o '\[[0-9:]*\]'
ls -l --time-style=+%H:%M /mnt/c/Users/irfan/Desktop/s10-postmarketos/images/
cat /mnt/c/Users/irfan/Desktop/s10-postmarketos/images/SHA256SUMS
