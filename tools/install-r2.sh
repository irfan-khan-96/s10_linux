#!/bin/bash
# Build fbterm r2 + s10-terminal r2 and install them on the phone (asks for WSL and phone sudo passwords).
set -e
R=~/.local/var/pmbootstrap/packages/edge/aarch64
cd ~/pmbootstrap && ./pmbootstrap.py build fbterm s10-terminal
cp $R/fbterm-1.7-r2.apk $R/s10-terminal-1-r2.apk /mnt/c/Users/irfan/Desktop/s10-postmarketos/
scp -q $R/fbterm-1.7-r2.apk $R/s10-terminal-1-r2.apk s10:
echo ">>> Enter the PHONE password when sudo asks:"
ssh -t s10 'sudo sh -c "apk add --allow-untrusted ~farmer/fbterm-1.7-r2.apk ~farmer/s10-terminal-1-r2.apk && rm -f ~farmer/*.apk /run/s10-osk-hidden && pkill -x fbterm; /usr/bin/s10-osk-start" && echo INSTALLED'
