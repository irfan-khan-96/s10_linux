#!/bin/bash
# Finish fbterm r3: checksums, patch-order check, commit.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/main/fbterm
cd "$P"
python3 "$T/resum.py" . | tail -2
grep -n 'pkgrel\|palette' APKBUILD
bash "$T/fbterm-order-test.sh" 2>&1 | grep -v IDENTICAL || true
cd ../..
git add -A main/fbterm
git -c user.name=khan -c user.email=khan@localhost commit -q -m "fbterm: rebuild fill colours when palette entries change" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
