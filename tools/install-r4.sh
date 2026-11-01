#!/bin/bash
# Build s10-terminal r4 (Syncthing) and install it on the phone (asks for WSL and phone sudo passwords).
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
R=~/.local/var/pmbootstrap/packages/edge/aarch64
cp "$T/s10-syncthing-setup" "$P/"
python3 "$T/resum.py" "$P" >/dev/null
(cd "$P" && git add -A . && git -c user.name=khan -c user.email=khan@localhost commit -q -m "s10-terminal: turn off Syncthing crash reporting" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" || true)
cd ~/pmbootstrap && ./pmbootstrap.py build s10-terminal
cp $R/s10-terminal-1-r4.apk /mnt/c/Users/irfan/Desktop/s10-postmarketos/
scp -q $R/s10-terminal-1-r4.apk s10:
echo ">>> Enter the PHONE password when sudo asks:"
ssh -t s10 'sudo sh -c "apk add --allow-untrusted ~farmer/s10-terminal-1-r4.apk && rm -f ~farmer/*.apk && ls /etc/local.d/*.apk-new 2>/dev/null; sh /etc/local.d/10-firewall.start && rc-service s10-syncthing start" &&
	sleep 8 && s10-syncthing-setup && echo INSTALLED'
