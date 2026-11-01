#!/bin/bash
# s10-terminal r2: show/hide the keyboard by resizing fbterm in place (needs fbterm r2).
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
cp "$T/s10-osk" "$P/s10-osk"
cat > "$P/s10-term" <<'EOF'
#!/bin/sh
# Terminal session for tty1: fbterm + tmux above the on-screen keyboard.
# s10-osk writes the keyboard height (1 while hidden) to the reserve file and
# sends fbterm SIGWINCH, so fbterm resizes without restarting.
[ -f "$HOME/.fbtermrc" ] || cp /usr/share/s10-terminal/fbtermrc "$HOME/.fbtermrc"
export TERM=fbterm
export FBTERM_RESERVE_FILE=/run/s10-osk-reserve
export FBTERM_RESERVE_BOTTOM="$(cat "$FBTERM_RESERVE_FILE" 2>/dev/null || echo 1100)"
exec fbterm -- tmux new -A -s main
EOF
cd "$P"
rm -rf __pycache__
python3 - <<'EOF'
import hashlib, re
s = open("APKBUILD").read()
s = re.sub(r"^pkgrel=\d+$", "pkgrel=2", s, flags=re.M)
s = re.sub(r"(depends=\"[^\"]*?)\bfbterm\b(?!>)", r"\1fbterm>=1.7-r2", s)
for f in ("s10-osk", "s10-term"):
    h = hashlib.sha512(open(f, "rb").read()).hexdigest()
    s = re.sub(rf"^[0-9a-f]{{128}}  {re.escape(f)}$", f"{h}  {f}", s, flags=re.M)
open("APKBUILD", "w").write(s)
EOF
python3 -c "import ast; ast.parse(open('s10-osk').read())" && echo PY_OK
sh -n s10-term && echo SH_OK
grep -n '^pkgrel\|fbterm' APKBUILD | head -5
cd ../../..
git add -A main/fbterm device/downstream/s10-terminal
git -c user.name=khan -c user.email=khan@localhost commit -q -m "fbterm, s10-terminal: resize in place when the keyboard shows or hides" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
