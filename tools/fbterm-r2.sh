#!/bin/bash
# fbterm r2: live resize of the reserved bottom strip on SIGWINCH (no restart needed).
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/main/fbterm
cd ~/fbterm-src/fbterm-1.7
git checkout -q -- . && python3 "$T/fbterm-live-resize.py"
grep -n "class FbShell\b\|class FbShell " src/fbshell.h
grep -n "void resize" src/lib/shell.h src/fbshell.h
git diff --no-prefix --src-prefix=a/ --dst-prefix=b/ > "$P/live-resize.patch"
sed -i 's|^diff --git src/|diff --git a/src/|' "$P/live-resize.patch"
cd "$P"
head -5 live-resize.patch; wc -l live-resize.patch
python3 - <<'EOF'
import hashlib, re
s = open("APKBUILD").read()
s = s.replace("pkgrel=1\n", "pkgrel=2\n", 1)
if "live-resize.patch" not in s:
    s = s.replace("\treserve-bottom.patch\n\t\"", "\treserve-bottom.patch\n\tlive-resize.patch\n\t\"")
    s = s.rstrip('"\n') + "\nXXXX  live-resize.patch\n\"\n"
h = hashlib.sha512(open("live-resize.patch", "rb").read()).hexdigest()
s = re.sub(r"^\S+  live-resize.patch$", f"{h}  live-resize.patch", s, flags=re.M)
open("APKBUILD", "w").write(s)
EOF
grep -n "pkgrel\|patch" APKBUILD
