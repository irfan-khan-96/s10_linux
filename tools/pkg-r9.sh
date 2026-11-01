#!/bin/bash
# s10-terminal r9: Alt+m finds the existing menu (tmux expanded #W inside if-shell; needs ##W).
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
cd "$P"
sed -i "s|tmux list-windows -F '#W' \| grep -qx menu|tmux list-windows -F '##W' \| grep -qx menu|" tmux.conf
sed -i 's|^# Alt+m: back to the launcher (reopened if it was closed)$|# Alt+m: back to the launcher (reopened if it was closed); ##W because tmux\n# expands formats in the if-shell command before the shell runs it|' tmux.conf
sed -i 's/^pkgrel=[0-9]*$/pkgrel=9/' APKBUILD
python3 "$T/resum.py" . >/dev/null
tail -3 tmux.conf; grep -n '^pkgrel' APKBUILD
cd ../../..
git add -A device/downstream/s10-terminal
git -c user.name=khan -c user.email=khan@localhost commit -q -m "s10-terminal: Alt+m reuses the existing menu window" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
