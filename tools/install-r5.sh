#!/bin/bash
# Build s10-terminal r5 and install it on the phone: removes Syncthing, adds the 85% charge
# limit and the screen-wake fix (asks for WSL and phone sudo passwords).
set -e
R=~/.local/var/pmbootstrap/packages/edge/aarch64
cd ~/pmbootstrap && ./pmbootstrap.py build s10-terminal
cp $R/s10-terminal-1-r5.apk /mnt/c/Users/irfan/Desktop/s10-postmarketos/
scp -q $R/s10-terminal-1-r5.apk s10:
echo ">>> Enter the PHONE password when sudo asks:"
ssh -t s10 'sudo sh -c "rc-service s10-syncthing stop 2>/dev/null; apk add --allow-untrusted ~farmer/s10-terminal-1-r5.apk && apk del syncthing && rm -f ~farmer/*.apk ~farmer/probe-root.*; ls /etc/local.d/*.apk-new 2>/dev/null; sh /etc/local.d/10-firewall.start; sh /etc/local.d/45-s10-battery.start; /usr/bin/s10-osk-start" &&
	rm -rf ~/.config/syncthing && echo INSTALLED'
