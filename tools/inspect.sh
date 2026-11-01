#!/bin/bash
cd ~/.local/var/pmbootstrap/cache_git/pmaports/device/archived || exit 1
for f in device-samsung-beyond1lte-downstream/APKBUILD device-samsung-beyond1lte-downstream/deviceinfo \
         device-samsung-beyond1lte-downstream/initfs-hook.sh device-samsung-beyond1lte-downstream/kernel-cmdline.conf \
         firmware-samsung-beyond1lte/APKBUILD linux-samsung-beyond1lte-downstream/APKBUILD; do
  echo "===== $f"; cat "$f"
done
echo "===== history"
git -C .. log --format='%h %ad %s' --date=short -5 -- device/archived/device-samsung-beyond1lte-downstream device/archived/linux-samsung-beyond1lte-downstream
