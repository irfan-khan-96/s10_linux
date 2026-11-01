#!/bin/bash
# Build s10-terminal r1 and install it on the phone (asks for the WSL and phone sudo passwords).
set -e
rm -rf ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal/__pycache__
cd ~/pmbootstrap && ./pmbootstrap.py build s10-terminal
APK=$(ls -t ~/.local/var/pmbootstrap/packages/edge/aarch64/s10-terminal-1-r1.apk)
cp "$APK" /mnt/c/Users/irfan/Desktop/s10-postmarketos/
scp -q "$APK" s10:
ssh -t s10 'sudo apk add --allow-untrusted ~/s10-terminal-1-r1.apk && rm ~/s10-terminal-1-r1.apk && sudo /usr/bin/s10-osk-start && echo INSTALLED'
