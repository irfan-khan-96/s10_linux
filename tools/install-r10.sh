#!/bin/bash
# Build s10-terminal r10 (look and feel) and install it on the phone (asks for WSL and
# phone sudo passwords). Shows the boot splash once, then restarts the terminal.
set -e
R=~/.local/var/pmbootstrap/packages/edge/aarch64
cd ~/pmbootstrap && ./pmbootstrap.py build s10-terminal
cp $R/s10-terminal-1-r10.apk /mnt/c/Users/irfan/Desktop/s10-postmarketos/
scp -q $R/s10-terminal-1-r10.apk s10:
echo ">>> Enter the PHONE password when sudo asks:"
ssh -t s10 'sudo sh -c "apk add --allow-untrusted ~farmer/s10-terminal-1-r10.apk && rm -f ~farmer/*.apk; ls /etc/*.apk-new 2>/dev/null; /usr/bin/s10-splash; sleep 3; /usr/bin/s10-osk-start; pkill -x fbterm" &&
	sleep 3 && tmux source-file /etc/tmux.conf && tmux respawn-window -k -t menu s10-menu && echo INSTALLED'
