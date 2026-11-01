#!/bin/bash
F=$(find ~/s10-bb/lvgl -name lv_linux_fbdev.c | head -1)
sed -n 192,206p "$F"; echo ....; sed -n 266,330p "$F"
echo ==== lvgl dir shipped inside buffybox tarball?
ls ~/s10-bb/src/buffybox-3.6.0/lvgl | head
