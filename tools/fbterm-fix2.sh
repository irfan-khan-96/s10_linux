#!/bin/bash
set -e
cd ~/s10-fbterm
rm -rf m && mkdir m && tar -xzf fbterm_1.7.orig.tar.gz -C m
cp -r m/fbterm-1.7 m/a; cp -r m/fbterm-1.7 m/b
python3 - <<'EOF'
p = "m/b/src/fbterm.cpp"; s = open(p).read()
s = s.replace('// <sys/signalfd.h> offered by some systems has bug with g++\n#include "signalfd.h"',
              '// musl: use the system header (the bundled copy needs glibc macros)\n#include <sys/signalfd.h>', 1)
s = s.replace('#include "config.h"\n', '#include "config.h"\n\n#ifndef WAIT_ANY\n#define WAIT_ANY (-1) /* glibc-only alias */\n#endif\n', 1)
open(p, "w").write(s)
p = "m/b/src/improxy.cpp"; s = open(p).read()
s = s.replace('#include <sys/socket.h>\n', '#include <sys/socket.h>\n#include <sys/select.h>\n#include <sys/time.h>\n', 1)
open(p, "w").write(s)
EOF
P=~/.local/var/pmbootstrap/cache_git/pmaports/main/fbterm
(cd m && diff -ru a b | sed 's|^--- a/|--- a/|; s|^+++ b/|+++ b/|' > $P/musl-compat.patch) || true
sed -i -E 's/^(diff -ru a\/(.*) b\/.*)$/\1/' $P/musl-compat.patch
cat $P/musl-compat.patch
cd $P
python3 - <<'EOF'
p = "APKBUILD"; s = open(p).read()
if "musl-compat.patch" not in s:
    s = s.replace('$pkgver-$_debrel.debian.tar.xz\n\t"', '$pkgver-$_debrel.debian.tar.xz\n\tmusl-compat.patch\n\t"', 1)
    open(p, "w").write(s)
EOF
h=$(sha512sum musl-compat.patch | cut -d' ' -f1)
python3 - "$h" <<'EOF'
import sys
h = sys.argv[1]; p = "APKBUILD"; s = open(p).read()
line = f"{h}  musl-compat.patch\n"
import re
s = re.sub(r"^[0-9a-f]{128}  musl-compat\.patch\n", "", s, flags=re.M)
head, sums = s.split('sha512sums="\n', 1); body, tail = sums.split('"\n', 1)
open(p, "w").write(head + 'sha512sums="\n' + body + line + '"\n' + tail)
EOF
sed -n '/^source=/,/^"/p;/^sha512sums=/,/^"/p' APKBUILD | cut -c1-70
cd ../..
git add main/fbterm/musl-compat.patch
git -c user.name=khan -c user.email=khan@localhost commit -qam "fbterm: musl compatibility patch"
git log -1 --oneline
