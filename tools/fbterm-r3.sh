#!/bin/bash
# fbterm r3: rebuild the fill colours whenever a palette entry changes. Screen::setPalette
# returned early when handed the same palette object, so after the first "ESC [ 3;n;r;g;b }"
# only text picked up new colours and backgrounds kept the defaults.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/main/fbterm
cd ~/fbterm-src/fbterm-1.7
git checkout -q -- . && python3 "$T/fbterm-live-resize.py" >/dev/null
git add -A && git -c user.name=x -c user.email=x@x commit -qm live-resize
python3 - <<'EOF'
p = "src/screen_render.cpp"; s = open(p).read()
old = "\tif (mPalette == palette) return;\n\tmPalette = palette;\n"
assert s.count(old) == 1
s = s.replace(old, "\t/* no early return for the same palette: its entries may have changed */\n\tmPalette = palette;\n")
open(p, "w").write(s)
EOF
git diff --src-prefix=a/ --dst-prefix=b/ > "$P/palette-refresh.patch"
git reset -q --hard HEAD~1
cd "$P"
python3 - <<'EOF'
import re
s = open("APKBUILD").read()
s = re.sub(r"^pkgrel=\d+$", "pkgrel=3", s, flags=re.M)
if "palette-refresh.patch" not in s:
    s = s.replace("\tlive-resize.patch\n\t\"", "\tlive-resize.patch\n\tpalette-refresh.patch\n\t\"")
    s = s.rstrip('"\n') + "\nX  palette-refresh.patch\n\"\n"
open("APKBUILD", "w").write(s)
EOF
python3 "$T/resum.py" . | tail -3
bash "$T/fbterm-order-test.sh" 2>&1 | head -4 || true
cd ../..
git add -A main/fbterm
git -c user.name=khan -c user.email=khan@localhost commit -q -m "fbterm: rebuild fill colours when palette entries change" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
