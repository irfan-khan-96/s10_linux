#!/bin/bash
# Build s10-terminal r7 (no gettys on tty2-6) and install it; switches back to console 1
# (asks for WSL and phone sudo passwords).
set -e
R=~/.local/var/pmbootstrap/packages/edge/aarch64
cd ~/pmbootstrap && ./pmbootstrap.py build s10-terminal
cp $R/s10-terminal-1-r7.apk /mnt/c/Users/irfan/Desktop/s10-postmarketos/
scp -q $R/s10-terminal-1-r7.apk s10:
echo ">>> Enter the PHONE password when sudo asks:"
ssh -t s10 'sudo sh -c "apk add --allow-untrusted ~farmer/s10-terminal-1-r7.apk && rm -f ~farmer/*.apk; chvt 1; sleep 1; pkill -f \"getty 38400 tty[2-6]\"; sleep 1; deallocvt 2>/dev/null; grep ^tty /etc/inittab; cat /sys/class/tty/tty0/active" && echo INSTALLED'
