#!/bin/bash
# Build the current s10-terminal (and fbterm with --fbterm) and install on the phone, restarting
# the keyboard program, and the terminal with --restart-term (asks for WSL and phone sudo passwords).
# Usage: install-terminal.sh [--fbterm] [--restart-term]
set -e
R=~/.local/var/pmbootstrap/packages/edge/aarch64
PM=~/.local/var/pmbootstrap/cache_git/pmaports
pkgs=(s10-terminal); restart=""
for a in "$@"; do
	case $a in --fbterm) pkgs+=(fbterm);; --restart-term) restart="; pkill -x fbterm";; esac
done
apks=()
for p in "${pkgs[@]}"; do
	dir=$(dirname "$(ls $PM/*/$p/APKBUILD $PM/device/*/$p/APKBUILD 2>/dev/null | head -1)")
	ver=$(sed -n 's/^pkgver=//p' "$dir/APKBUILD"); rel=$(sed -n 's/^pkgrel=//p' "$dir/APKBUILD")
	apks+=("$p-$ver-r$rel.apk")
done
cd ~/pmbootstrap && ./pmbootstrap.py build "${pkgs[@]}"
for a in "${apks[@]}"; do cp "$R/$a" /mnt/c/Users/irfan/Desktop/s10-postmarketos/; scp -q "$R/$a" s10:; done
list=$(printf '~farmer/%s ' "${apks[@]}")
echo ">>> Enter the PHONE password when sudo asks:"
ssh -t s10 "sudo sh -c 'apk add --allow-untrusted $list && rm -f ~farmer/*.apk; ls /etc/*.apk-new 2>/dev/null; /usr/bin/s10-osk-start$restart' && sleep 3 && tmux source-file /etc/tmux.conf && tmux respawn-window -k -t menu s10-menu; echo INSTALLED ${apks[*]}"
