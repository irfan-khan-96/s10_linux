#!/bin/bash
set -e
mkdir -p ~/s10-fbterm && cd ~/s10-fbterm
B=https://deb.debian.org/debian/pool/main/f/fbterm
for f in fbterm_1.7.orig.tar.gz fbterm_1.7-5.debian.tar.xz; do
  [ -f $f ] || curl -fsSLO "$B/$f"
done
ls -la
tar -tzf fbterm_1.7.orig.tar.gz | head -3
tar -tJf fbterm_1.7-5.debian.tar.xz | grep patches
sha512sum fbterm_1.7.orig.tar.gz fbterm_1.7-5.debian.tar.xz
rm -rf x && mkdir x && tar -xJf fbterm_1.7-5.debian.tar.xz -C x
for p in $(cat x/debian/patches/series); do echo "== $p"; grep -E '^(\+\+\+|---) ' x/debian/patches/$p | head -4; done
tar -xzf fbterm_1.7.orig.tar.gz -C x
d=$(ls -d x/fbterm-*)
echo "== musl concerns"; grep -rn "execinfo\|sys/io.h\|ioperm\|iopl\|backtrace" $d/src | head
