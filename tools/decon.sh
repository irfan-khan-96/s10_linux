#!/bin/bash
set -e
T=$(ls ~/.local/var/pmbootstrap/cache_distfiles/linux-samsung-beyond1lte-downstream-*.tar.gz | head -1)
cd ~/s10-kernel
top=$(tar -tzf "$T" | head -1 | cut -d/ -f1)
if [ ! -d "$top/drivers/video/fbdev/exynos" ]; then
  tar -xzf "$T" --wildcards "$top/drivers/video/fbdev/exynos/dpu*/decon*" 2>/dev/null || true
fi
D=$(ls -d $top/drivers/video/fbdev/exynos/dpu* | head -1); echo "dir: $D"
echo "== decon_state enum"; grep -n -A12 'enum decon_state' $D/decon.h
echo "== pan_display"; grep -n -B3 -A25 '^static int decon_pan_display\|^int decon_pan_display' $D/decon_core.c | head -50
echo "== blank handler"; grep -n -A40 '^static int decon_blank' $D/decon_core.c | head -60
