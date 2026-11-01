#!/bin/bash
# Run in WSL: r9 on the phone, and which s10-terminal the last image build used.
ssh s10 'apk list -I s10-terminal; grep -c "##W" /etc/tmux.conf; ls /etc/tmux.conf.apk-new 2>&1'
ls -l --time-style=+%H:%M /mnt/c/Users/irfan/Desktop/s10-postmarketos/images/
cat /mnt/c/Users/irfan/Desktop/s10-postmarketos/images/SHA256SUMS
grep -o -E 'rootfs_samsung[^ ]* .*s10-terminal-1-r[0-9]+\.apk' ~/.local/var/pmbootstrap/log.txt | grep -o 's10-terminal-1-r[0-9]*' | tail -1
grep -E 'Export symlinks|ssh key' ~/.local/var/pmbootstrap/log.txt | tail -1
