#!/bin/bash
set -e
mkdir -p ~/s10-bb && cd ~/s10-bb
f=buffybox-3.6.0.tar.gz
[ -s $f ] || curl -fsSL -o $f "https://gitlab.postmarketos.org/postmarketOS/buffybox/-/archive/3.6.0/buffybox-3.6.0.tar.gz" || true
file $f; sha512sum $f | cut -c1-40
echo "expected 368938531616c1fd517c99e419b2ff38"
rm -rf src && mkdir src && tar -xzf $f -C src 2>/dev/null && ls src
grep -rn "LV_LINUX_FBDEV_MMAP\|LV_USE_LINUX_FBDEV\|LV_LINUX_FBDEV_BUFFER" src/*/ --include=*.h --include=*.build --include=*.txt 2>/dev/null | head
