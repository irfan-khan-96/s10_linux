#!/bin/bash
set -e
cd ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/linux-samsung-beyond1lte-downstream
h=$(sha512sum loop-dio-blockdev-bsize.patch | cut -d' ' -f1)
python3 - "$h" <<'EOF'
import sys
h = sys.argv[1]; p = "APKBUILD"
line = f"{h}  loop-dio-blockdev-bsize.patch\n"
s = open(p).read().replace(line, "")
head, sums = s.split('sha512sums="\n', 1)
body, tail = sums.split('"\n', 1)
s = head + 'sha512sums="\n' + body + line + '"\n' + tail
open(p, "w").write(s)
EOF
sed -n '/^source=/,/^"/p;/^sha512sums=/,/^"/p' APKBUILD | cut -c1-40
git add loop-dio-blockdev-bsize.patch
git -c user.name="khan" -c user.email="khan@localhost" commit -qam "linux-samsung-beyond1lte-downstream: fix loop direct I/O on 4K block devices"
git log -1 --oneline
