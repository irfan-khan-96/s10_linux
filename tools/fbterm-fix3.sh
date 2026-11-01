#!/bin/bash
set -e
cd ~/.local/var/pmbootstrap/cache_git/pmaports
grep -q '^subpackages=' main/fbterm/APKBUILD || sed -i 's/^options="!check"$/options="!check"\nsubpackages="$pkgname-doc"/' main/fbterm/APKBUILD
grep -n 'subpackages\|options' main/fbterm/APKBUILD
git -c user.name=khan -c user.email=khan@localhost commit -qam "fbterm: split man pages into -doc"
git log -1 --oneline
