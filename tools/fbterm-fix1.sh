#!/bin/bash
set -e
cd ~/.local/var/pmbootstrap/cache_git/pmaports
sed -i 's/^makedepends="autoconf automake fontconfig-dev freetype-dev ncurses"$/makedepends="autoconf automake fontconfig-dev freetype-dev linux-headers ncurses"/' main/fbterm/APKBUILD
grep -n makedepends main/fbterm/APKBUILD
git -c user.name=khan -c user.email=khan@localhost commit -qam "fbterm: add linux-headers"
git log -1 --oneline
