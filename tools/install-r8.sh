#!/bin/bash
# Build s10-terminal r8 (landscape with a USB keyboard) and install it on the phone
# (asks for WSL and phone sudo passwords).
set -e
R=~/.local/var/pmbootstrap/packages/edge/aarch64
cd ~/pmbootstrap && ./pmbootstrap.py build s10-terminal
cp $R/s10-terminal-1-r8.apk /mnt/c/Users/irfan/Desktop/s10-postmarketos/
scp -q $R/s10-terminal-1-r8.apk s10:
echo ">>> Enter the PHONE password when sudo asks:"
ssh -t s10 'sudo sh -c "apk add --allow-untrusted ~farmer/s10-terminal-1-r8.apk && rm -f ~farmer/*.apk && /usr/bin/s10-osk-start" && echo INSTALLED'
