#!/bin/bash
set -e
cd ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/linux-samsung-beyond1lte-downstream
git mv config-samsung-beyond1lte.aarch64 config-samsung-beyond1lte-downstream.aarch64
sed -i 's/^_flavor="samsung-beyond1lte"$/_flavor="samsung-beyond1lte-downstream"/' APKBUILD
sed -i 's/  config-samsung-beyond1lte\.aarch64$/  config-samsung-beyond1lte-downstream.aarch64/' APKBUILD
sed -i 's/^pkgrel=0$/pkgrel=1/' APKBUILD
grep -nE '^_flavor|^pkgrel|config-samsung' APKBUILD
sha512sum config-samsung-beyond1lte-downstream.aarch64 | cut -c1-20
git -c user.name="khan" -c user.email="khan@localhost" commit -qam "linux-samsung-beyond1lte-downstream: rename config to match pkgname"
git log -1 --oneline
