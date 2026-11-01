#!/bin/bash
# s10-terminal r8: landscape while a USB keyboard is plugged in.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
cp "$T/s10-osk" "$T/s10-term" "$P/"
cd "$P"
sed -i 's/^pkgrel=[0-9]*$/pkgrel=8/' APKBUILD
python3 "$T/resum.py" . >/dev/null
python3 -c "import ast; ast.parse(open('s10-osk').read())" && sh -n s10-term && echo OK
grep -n '^pkgrel' APKBUILD
cd ../../..
git add -A device/downstream/s10-terminal
git -c user.name=khan -c user.email=khan@localhost commit -q -m "s10-terminal: landscape while a USB keyboard is plugged in" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
