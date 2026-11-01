#!/bin/bash
set -e
cd ~/s10-fbterm
rm -rf r && mkdir r && tar -xzf fbterm_1.7.orig.tar.gz -C r
cp -r r/fbterm-1.7 r/a; cp -r r/fbterm-1.7 r/b
python3 - <<'EOF'
p = "r/b/src/fbdev.cpp"; s = open(p).read()
old_h = "\tmHeight = vinfo.yres;\n"
new_h = """\tmHeight = vinfo.yres;
	/*
	 * FBTERM_RESERVE_BOTTOM=<pixels> leaves a strip at the bottom of the
	 * screen untouched, e.g. for an on-screen keyboard drawn by another
	 * program (buffyboard). Panning would move that strip, so scroll by
	 * redrawing instead.
	 */
	const char *reserve = getenv("FBTERM_RESERVE_BOTTOM");
	u32 reserved = reserve ? strtoul(reserve, 0, 10) : 0;
	if (reserved >= mHeight) reserved = 0;
	mHeight -= reserved;
"""
old_r = "\tif (mRotateType == Rotate0 || mRotateType == Rotate180) {\n\t\tbool ypan"
new_r = "\tif (!reserved && (mRotateType == Rotate0 || mRotateType == Rotate180)) {\n\t\tbool ypan"
assert s.count(old_h) == 1 and s.count(old_r) == 1
s = s.replace(old_h, new_h).replace(old_r, new_r)
if "#include <stdlib.h>" not in s:
    s = s.replace("#include <stdio.h>\n", "#include <stdio.h>\n#include <stdlib.h>\n", 1)
open(p, "w").write(s)
EOF
grep -n "#include" r/b/src/fbdev.cpp | head
P=~/.local/var/pmbootstrap/cache_git/pmaports/main/fbterm
(cd r && diff -ru a b > $P/reserve-bottom.patch) || true
cat $P/reserve-bottom.patch
cd $P
python3 - <<'EOF'
p = "APKBUILD"; s = open(p).read()
if "reserve-bottom.patch" not in s:
    s = s.replace("\tmusl-compat.patch\n", "\tmusl-compat.patch\n\treserve-bottom.patch\n", 1)
    s = s.replace("pkgrel=0\n", "pkgrel=1\n", 1)
    open(p, "w").write(s)
EOF
h=$(sha512sum reserve-bottom.patch | cut -d' ' -f1)
python3 - "$h" <<'EOF'
import sys, re
h = sys.argv[1]; p = "APKBUILD"; s = open(p).read()
s = re.sub(r"^[0-9a-f]{128}  reserve-bottom\.patch\n", "", s, flags=re.M)
head, sums = s.split('sha512sums="\n', 1); body, tail = sums.split('"\n', 1)
open(p, "w").write(head + 'sha512sums="\n' + body + f"{h}  reserve-bottom.patch\n" + '"\n' + tail)
EOF
grep -nE "^pkgrel|reserve-bottom" APKBUILD | cut -c1-80
cd ../..
git add main/fbterm/reserve-bottom.patch
git -c user.name=khan -c user.email=khan@localhost commit -qam "fbterm: FBTERM_RESERVE_BOTTOM for an on-screen keyboard"
git log -1 --oneline
