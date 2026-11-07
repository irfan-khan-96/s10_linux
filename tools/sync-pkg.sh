#!/bin/bash
# Copy pkg/ (the s10-terminal source) into the fork, set pkgrel, fix checksums, commit.
# Usage: sync-pkg.sh <pkgrel> "<commit message>"
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
S=/mnt/c/Users/irfan/Desktop/s10-postmarketos/pkg
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
sed -i "s/^pkgrel=[0-9]*$/pkgrel=$1/" "$S/APKBUILD"
bash "$T/check-pkg.sh" | grep -v ' ok ' || true
chmod -R u+rwX "$P" && rm -rf "$P"/* && cp "$S"/* "$P"/ && chmod 644 "$P"/*   # files only, no __pycache__
python3 "$T/resum.py" "$P" >/dev/null
cp "$P/APKBUILD" "$S/APKBUILD"
cd "$P/../../.."
git add -A device/downstream/s10-terminal
git -c user.name=khan -c user.email=khan@localhost commit -q -m "$2" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
grep -n '^pkgrel' device/downstream/s10-terminal/APKBUILD
