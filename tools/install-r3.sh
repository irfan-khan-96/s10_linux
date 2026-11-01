#!/bin/bash
# Build s10-terminal r3 (launcher) and install it on the phone (asks for WSL and phone sudo passwords).
set -e
R=~/.local/var/pmbootstrap/packages/edge/aarch64
cd ~/pmbootstrap && ./pmbootstrap.py build s10-terminal
cp $R/s10-terminal-1-r3.apk /mnt/c/Users/irfan/Desktop/s10-postmarketos/
scp -q $R/s10-terminal-1-r3.apk s10:
echo ">>> Enter the PHONE password when sudo asks:"
ssh -t s10 'sudo sh -c "apk add --allow-untrusted ~farmer/s10-terminal-1-r3.apk && rm -f ~farmer/*.apk && if [ -e /etc/tmux.conf.apk-new ]; then mv /etc/tmux.conf.apk-new /etc/tmux.conf; fi" &&
	rm -f ~/.cache/s10-menu && tmux source-file /etc/tmux.conf &&
	tmux kill-window -t menu; tmux new-window -b -t main:1 -n menu s10-menu && echo INSTALLED'
