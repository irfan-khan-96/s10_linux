#!/bin/bash
# Build fbterm r3 + s10-terminal r11 (colour fixes) and install them; restarts the terminal
# (asks for WSL and phone sudo passwords).
set -e
R=~/.local/var/pmbootstrap/packages/edge/aarch64
cd ~/pmbootstrap && ./pmbootstrap.py build fbterm s10-terminal
cp $R/fbterm-1.7-r3.apk $R/s10-terminal-1-r11.apk /mnt/c/Users/irfan/Desktop/s10-postmarketos/
scp -q $R/fbterm-1.7-r3.apk $R/s10-terminal-1-r11.apk s10:
echo ">>> Enter the PHONE password when sudo asks:"
ssh -t s10 'sudo sh -c "apk add --allow-untrusted ~farmer/fbterm-1.7-r3.apk ~farmer/s10-terminal-1-r11.apk && rm -f ~farmer/*.apk; ls /etc/*.apk-new 2>/dev/null; pkill -x fbterm" &&
	sleep 3 && tmux source-file /etc/tmux.conf && echo INSTALLED'
