#!/bin/bash
# Run in WSL: check the last image build (from its "install" onwards in the pmbootstrap log):
# which of our packages went in, warnings, the SSH key copy, and the exported files.
L=~/.local/var/pmbootstrap/log.txt
start=$(grep -n 'CREATE DEVICE ROOTFS' "$L" | tail -1 | cut -d: -f1)
tail -n +"$start" "$L" > /tmp/lastbuild.log
echo "packages: $(grep -o -E '(s10-terminal|fbterm|device-samsung-beyond1lte-downstream|linux-samsung-beyond1lte-downstream|firmware-samsung-beyond1lte|postmarketos-base-ui)-[0-9.]+-r[0-9]+' /tmp/lastbuild.log | sort -u | tr '\n' ' ')"
echo "warnings: $(grep -c 'WARNING' /tmp/lastbuild.log)"; grep 'WARNING' /tmp/lastbuild.log | sort -u | head -5
grep -q 'mnt/install/home/.*/.ssh/authorized_keys' /tmp/lastbuild.log && echo "ssh key: copied into image"
grep -o 'Export symlinks.*' /tmp/lastbuild.log | tail -1
ls -l --time-style=+%H:%M /mnt/c/Users/irfan/Desktop/s10-postmarketos/images/ | tail -3
cat /mnt/c/Users/irfan/Desktop/s10-postmarketos/images/SHA256SUMS
