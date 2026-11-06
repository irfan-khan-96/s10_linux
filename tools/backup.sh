#!/bin/bash
# Back up the fork into the project: our commits as patches + a git bundle (on top of the
# upstream commit in patches/BASE), historical helper scripts, the pmbootstrap config.
# The s10-terminal package source lives in pkg/, not here.
set -e
SP=$(dirname "$0")
DST=/mnt/c/Users/irfan/Desktop/s10-postmarketos
mkdir -p "$DST/patches" "$DST/scripts"
cd ~/.local/var/pmbootstrap/cache_git/pmaports
base=$(git merge-base origin/main s10-downstream)
rm -f "$DST"/patches/*.patch
git format-patch -q "$base..s10-downstream" -o "$DST/patches"
git log -1 --format='%H %cd %s' --date=short "$base" > "$DST/patches/BASE"
git bundle create "$DST/s10-downstream.bundle" "$base..s10-downstream" 2>/dev/null
for f in odin.sh unsparse.py gpt.py verify.py serial.ps1 acm.py harden.sh debugboot.py sxmo.sh display.sh fbtest.py polish.sh usbfix.sh touchfix.sh touchfix2.sh touchfix3.sh restartx.sh tune.sh tune2.sh termcfg.sh termtest.sh nosxmo.sh osk-start.sh osk.sh fbshot.py fb2png.py fbscan.py; do
	cp "$SP/$f" "$DST/scripts/" 2>/dev/null || true
done
rm -f "$DST/scripts/s10-osk" "$DST/scripts/s10-idle-blank"   # superseded by pkg/
cp ~/.config/pmbootstrap_v3.cfg "$DST/pmbootstrap_v3.cfg"
echo "$(ls "$DST"/patches/*.patch | wc -l) patches on $(cut -c1-10 "$DST/patches/BASE")"
