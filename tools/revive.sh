#!/bin/bash
set -e
cd ~/.local/var/pmbootstrap/cache_git/pmaports
git switch -c s10-downstream 2>/dev/null || git switch s10-downstream
mkdir -p device/downstream
for p in device-samsung-beyond1lte-downstream linux-samsung-beyond1lte-downstream firmware-samsung-beyond1lte; do
  [ -d "device/archived/$p" ] && git mv "device/archived/$p" "device/downstream/$p"
done
ls device/downstream | grep beyond1lte
# msm-fb-refresher still packaged?
find . -path ./device -prune -o -type d -name 'msm-fb-refresher' -print
grep -rl 'msm-fb-refresher' --include=APKBUILD . | head -3
git -c user.name="khan" -c user.email="khan@localhost" commit -qm "samsung-beyond1lte-downstream: revive archived port (local)" || true
git log -1 --oneline
