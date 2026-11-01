#!/bin/bash
set -e
C=05c9ef8f16e0ad5ab274e408c120dfd99fd5c628
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/firmware-samsung-beyond1lte
cd /tmp && rm -f mfc_fw.bin
curl -fsSLo mfc_fw.bin "https://github.com/Linux4/proprietary_vendor_samsung/raw/$C/exynos9820-common/proprietary/vendor/firmware/mfc_fw.bin"
ls -la mfc_fw.bin
h=$(sha512sum mfc_fw.bin | cut -d' ' -f1)
cd $P
python3 - "$h" <<'EOF'
import sys, re
h = sys.argv[1]; p = "APKBUILD"; s = open(p).read()
if "mfc_fw.bin" not in s:
    s = s.replace('_wifi_files_common="bcmdhd_mfg.bin_b1', '_wifi_files_common="mfc_fw.bin bcmdhd_mfg.bin_b1', 1)
    s = s.replace("pkgrel=1\n", "pkgrel=2\n", 1)
    line = f"{h}  firmware-samsung-beyond1lte-05c9ef8f16e0ad5ab274e408c120dfd99fd5c628-mfc_fw.bin\n"
    head, sums = s.split('sha512sums="\n', 1); body, tail = sums.split('"\n', 1)
    s = head + 'sha512sums="\n' + line + body + '"\n' + tail
    open(p, "w").write(s)
EOF
grep -nE '^pkgrel|_wifi_files_common=|mfc_fw' APKBUILD | cut -c1-120
cd ~/.local/var/pmbootstrap/cache_git/pmaports
git -c user.name=khan -c user.email=khan@localhost commit -qam "firmware-samsung-beyond1lte: add MFC video codec firmware (fixes 3-min boot)"
git log -1 --oneline
