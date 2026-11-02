#!/bin/bash
# Build the current s10-terminal and install it on the phone, restarting the keyboard
# program (asks for WSL and phone sudo passwords). Usage: install-terminal.sh [--restart-term]
set -e
R=~/.local/var/pmbootstrap/packages/edge/aarch64
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
rel=$(sed -n 's/^pkgrel=//p' "$P/APKBUILD")
apk=s10-terminal-1-r$rel.apk
cd ~/pmbootstrap && ./pmbootstrap.py build s10-terminal
cp "$R/$apk" /mnt/c/Users/irfan/Desktop/s10-postmarketos/
scp -q "$R/$apk" s10:
restart=""
[ "$1" = --restart-term ] && restart="; pkill -x fbterm"
echo ">>> Enter the PHONE password when sudo asks:"
ssh -t s10 "sudo sh -c 'apk add --allow-untrusted ~farmer/$apk && rm -f ~farmer/*.apk; ls /etc/*.apk-new 2>/dev/null; /usr/bin/s10-osk-start$restart' && sleep 2 && tmux source-file /etc/tmux.conf && echo INSTALLED r$rel"
