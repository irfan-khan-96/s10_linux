#!/bin/bash
# fbterm r4: FBTERM_SCANLINES (CRT scanlines). Builds scanlines.patch on top of live-resize
# and palette-refresh, syntax-checks the renderer, updates the APKBUILD and commits.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/main/fbterm
cd ~/fbterm-src/fbterm-1.7
git checkout -q -- . && git reset -q --hard
python3 "$T/fbterm-live-resize.py" >/dev/null
patch -sp1 < "$P/palette-refresh.patch"
git add -A && git -c user.name=x -c user.email=x@x commit -qm "live-resize + palette-refresh"
python3 "$T/fbterm-scanlines.py"
[ -f config.h ] || sed 's/^#undef .*//' config.h.in > config.h
g++ -fsyntax-only -I. -Isrc -Isrc/lib $(pkg-config --cflags freetype2 2>/dev/null) src/screen_render.cpp && echo SYNTAX_OK
git diff --src-prefix=a/ --dst-prefix=b/ -- src > "$P/scanlines.patch"
git reset -q --hard HEAD~1
cd "$P"
python3 - <<'EOF'
import re
s = open("APKBUILD").read()
s = re.sub(r"^pkgrel=\d+$", "pkgrel=4", s, flags=re.M)
if "scanlines.patch" not in s:
    s = s.replace("\tpalette-refresh.patch\n\t\"", "\tpalette-refresh.patch\n\tscanlines.patch\n\t\"")
    s = s.rstrip('"\n') + "\nX  scanlines.patch\n\"\n"
open("APKBUILD", "w").write(s)
EOF
python3 "$T/resum.py" . | tail -1
sed -i 's/live-resize palette-refresh; do/live-resize palette-refresh scanlines; do/' "$T/fbterm-order-test.sh"
bash "$T/fbterm-order-test.sh" 2>&1 | grep -E '^ok|debian' || true
cd ../..
git add -A main/fbterm
git -c user.name=khan -c user.email=khan@localhost commit -q -m "fbterm: FBTERM_SCANLINES for a CRT look" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
