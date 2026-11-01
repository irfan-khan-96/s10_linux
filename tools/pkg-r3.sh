#!/bin/bash
# s10-terminal r3: launcher menu (s10-menu) in tmux window "menu", Alt+m to return to it.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
cp "$T/s10-menu" "$P/s10-menu"
cd "$P"
sed -i 's|^exec fbterm -- tmux new -A -s main$|exec fbterm -- tmux new -A -s main -n menu s10-menu|' s10-term
grep -q 's10-menu' tmux.conf || cat >> tmux.conf <<'EOF'
# Alt+m: back to the launcher (reopened if it was closed)
bind -n M-m if-shell "tmux list-windows -F '#W' | grep -qx menu" "select-window -t menu" "new-window -b -t 1 -n menu s10-menu"
EOF
python3 - <<'EOF'
import hashlib, re
s = open("APKBUILD").read()
s = re.sub(r"^pkgrel=\d+$", "pkgrel=3", s, flags=re.M)
if "s10-menu" not in s:
    s = s.replace("\ts10-osk\n", "\ts10-osk\n\ts10-menu\n", 1)
    s = s.replace('install -Dm755 "$srcdir"/s10-osk "$pkgdir"/usr/bin/s10-osk\n',
                  'install -Dm755 "$srcdir"/s10-osk "$pkgdir"/usr/bin/s10-osk\n'
                  '\tinstall -Dm755 "$srcdir"/s10-menu "$pkgdir"/usr/bin/s10-menu\n', 1)
    s = s.rstrip('"\n') + "\nXXXX  s10-menu\n\"\n"
for f in ("s10-menu", "s10-term", "tmux.conf"):
    h = hashlib.sha512(open(f, "rb").read()).hexdigest()
    s = re.sub(rf"^\S+  {re.escape(f)}$", f"{h}  {f}", s, flags=re.M)
open("APKBUILD", "w").write(s)
EOF
grep -n 'pkgrel\|s10-menu\|s10-osk' APKBUILD
tail -3 tmux.conf; tail -1 s10-term
cd ../../..
git add -A device/downstream/s10-terminal
git -c user.name=khan -c user.email=khan@localhost commit -q -m "s10-terminal: launcher menu, Alt+m returns to it" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
