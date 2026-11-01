#!/bin/bash
# Build s10-terminal r9 (Alt+m fix) and install it on the phone (asks for WSL and phone sudo passwords).
set -e
R=~/.local/var/pmbootstrap/packages/edge/aarch64
cd ~/pmbootstrap && ./pmbootstrap.py build s10-terminal
cp $R/s10-terminal-1-r9.apk /mnt/c/Users/irfan/Desktop/s10-postmarketos/
scp -q $R/s10-terminal-1-r9.apk s10:
echo ">>> Enter the PHONE password when sudo asks:"
ssh -t s10 'sudo sh -c "apk add --allow-untrusted ~farmer/s10-terminal-1-r9.apk && rm -f ~farmer/*.apk; ls /etc/tmux.conf.apk-new 2>/dev/null" && tmux source-file /etc/tmux.conf && echo INSTALLED'
