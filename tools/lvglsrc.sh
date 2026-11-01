#!/bin/bash
set -e
cd ~/s10-bb
C=85aa60d18b3d5e5588d7b247abf90198f07c8a63
f=lvgl-$C.tar.gz
[ -s $f ] || curl -fsSL -o $f "https://github.com/lvgl/lvgl/archive/$C.tar.gz"
rm -rf lvgl && mkdir lvgl && tar -xzf $f -C lvgl
F=$(find lvgl -name lv_linux_fbdev.c | head -1); echo "$F"
grep -n "MMAP\|mmap\|write(\|lseek\|force_refresh\|FBIOPUT\|FBIOPAN\|bits_per_pixel\|LV_COLOR_FORMAT" "$F" | head -50
