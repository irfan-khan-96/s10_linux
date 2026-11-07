#!/bin/bash
# Run in Git Bash on the PC after flashing a fresh image, with the phone on the USB cable:
# forget the old SSH host key, put the newest home backup back, then set the Wi-Fi and the
# Samba password (both asked for on the phone's side, nothing stored here).
set -e
# works from WSL or Git Bash (WSL has no USERPROFILE)
[ -n "$USERPROFILE" ] && [ -d "$USERPROFILE" ] || USERPROFILE=/mnt/c/Users/irfan
USB=(-o HostName=172.16.42.1 -o ConnectTimeout=5)
BACKUPS="$USERPROFILE/S10-backups"
ssh-keygen -R "$(ssh -G s10 | awk '/^hostname /{print $2}')" >/dev/null 2>&1 || true
ssh-keygen -R 172.16.42.1 >/dev/null 2>&1 || true
echo "waiting for the phone on USB (172.16.42.1) ..."
for i in $(seq 60); do
	ssh "${USB[@]}" -o StrictHostKeyChecking=accept-new -o BatchMode=yes s10 true 2>/dev/null && break
	sleep 5
done
ssh "${USB[@]}" -o BatchMode=yes s10 true || { echo "no SSH over USB; set Wi-Fi on the phone (sudo nmtui) and use: ssh s10"; exit 1; }
latest=$(ls -1 "$BACKUPS"/s10-home-*.tar.gz | sort | tail -1)
echo "restoring $latest"
ssh "${USB[@]}" s10 "tar xzf - -C /home/farmer" < "$latest"
ssh "${USB[@]}" s10 'ls ~ | tr "\n" " "; echo'
echo "--- Wi-Fi (asks for the Wi-Fi password, then your phone sudo password if needed)"
ssh -t "${USB[@]}" s10 'sudo nmcli --ask dev wifi connect "FRITZ!Box 7510 WW"'
echo "--- Samba password for the share"
ssh -t "${USB[@]}" s10 'sudo smbpasswd -a farmer'
ssh-keygen -R "$(ssh -G s10 | awk '/^hostname /{print $2}')" >/dev/null 2>&1 || true
ssh -o StrictHostKeyChecking=accept-new s10 'echo "over Wi-Fi: ok"; rc-status default | grep -E "samba|sshd|s10-"'
