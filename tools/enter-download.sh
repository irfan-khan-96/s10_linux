#!/bin/bash
# Run in Git Bash on the PC, phone on the USB cable: put the phone into Download mode for an
# Odin flash, without the worn buttons. Over USB (172.16.42.1), so it does not depend on Wi-Fi.
# It erases the first 1 MiB of the BOOT partition and reboots; the bootloader then stops in
# Download mode ("Could not do normal boot"). The phone will not boot again until it is flashed.
set -e
# works from WSL or Git Bash (WSL has no USERPROFILE; powershell.exe runs through interop)
[ -n "$USERPROFILE" ] && [ -d "$USERPROFILE" ] || USERPROFILE=/mnt/c/Users/irfan
USB=(-o HostName=172.16.42.1 -o ConnectTimeout=8)
ssh "${USB[@]}" -o BatchMode=yes s10 true || { echo "phone not reachable over USB; check the cable"; exit 1; }
part=$(ssh "${USB[@]}" s10 'readlink -f /dev/disk/by-partlabel/boot')
[ "$part" = /dev/sda14 ] || { echo "BOOT is $part, expected /dev/sda14: stopping"; exit 1; }
echo "Backing up the home folder first ..."
PS=$(command -v powershell.exe || echo /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe)
"$PS" -NoProfile -ExecutionPolicy Bypass -File "C:\\Users\\irfan\\Desktop\\s10-postmarketos\\tools\\pc-backup-phone.ps1"
tail -1 "$USERPROFILE/S10-backups/backup.log"
read -r -p "Erase BOOT ($part) and reboot into Download mode? Type yes: " ok
[ "$ok" = yes ] || { echo "cancelled"; exit 1; }
ssh -t "${USB[@]}" s10 "sudo dd if=/dev/zero of=$part bs=1M count=1 && sync && echo 'BOOT erased, rebooting' && sudo reboot"
echo "Now: Odin, AP = Downloads\\s10_pmos\\pmos-s10-AP.tar, Start. Then run tools/restore-phone.sh"
