#!/bin/bash
set -e
SP=$(dirname "$0")
DST=/mnt/c/Users/irfan/Desktop/s10-postmarketos
mkdir -p "$DST/patches" "$DST/scripts"
cd ~/.local/var/pmbootstrap/cache_git/pmaports
rm -f "$DST"/patches/*.patch
git format-patch -q main..s10-downstream -o "$DST/patches"
git bundle create "$DST/s10-downstream.bundle" main..s10-downstream 2>/dev/null
for f in odin.sh unsparse.py gpt.py verify.py serial.ps1 acm.py harden.sh debugboot.py sxmo.sh display.sh fbtest.py polish.sh usbfix.sh touchfix.sh touchfix2.sh touchfix3.sh restartx.sh tune.sh tune2.sh termcfg.sh termtest.sh nosxmo.sh s10-idle-blank s10-osk osk-start.sh osk.sh fbshot.py fb2png.py fbscan.py; do
  cp "$SP/$f" "$DST/scripts/"
done
cp ~/.config/pmbootstrap_v3.cfg "$DST/pmbootstrap_v3.cfg"
ls -la "$DST" "$DST/patches"
