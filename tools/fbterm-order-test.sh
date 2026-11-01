#!/bin/bash
# Apply patches in the APKBUILD's order (local first, then Debian) to check they all apply.
set -e
D=~/.local/var/pmbootstrap/cache_distfiles
P=~/.local/var/pmbootstrap/cache_git/pmaports/main/fbterm
rm -rf /tmp/fbt && mkdir /tmp/fbt && cd /tmp/fbt
tar xzf $D/fbterm_1.7.orig.tar.gz && tar xJf $D/fbterm_1.7-5.debian.tar.xz
cd fbterm-1.7
for p in musl-compat reserve-bottom live-resize; do patch -p1 --dry-run -i $P/$p.patch >/dev/null && patch -sp1 -i $P/$p.patch && echo "ok $p"; done
for p in $(cat ../debian/patches/series); do patch -sp1 -i ../debian/patches/$p; done && echo "debian ok"
diff -r -q . ~/fbterm-src/fbterm-1.7/ -x .git && echo "IDENTICAL to dev tree"
