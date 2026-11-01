#!/bin/bash
# Unpack fbterm 1.7 + Debian patches + our patches into ~/fbterm-src for reading/patching.
set -e
D=~/.local/var/pmbootstrap/cache_distfiles
P=~/.local/var/pmbootstrap/cache_git/pmaports/main/fbterm
rm -rf ~/fbterm-src && mkdir ~/fbterm-src && cd ~/fbterm-src
tar xzf $D/fbterm_1.7.orig.tar.gz && tar xJf $D/fbterm_1.7-5.debian.tar.xz
cd fbterm-1.7
for p in $(cat ../debian/patches/series); do patch -sp1 -i ../debian/patches/$p; done
patch -sp1 -i $P/musl-compat.patch; patch -sp1 -i $P/reserve-bottom.patch
git init -q && git add -A && git -c user.name=x -c user.email=x@x commit -qm base
ls src
grep -n "SIGWINCH\|signal\|SIG" src/*.cpp src/lib/*.cpp | head -40
