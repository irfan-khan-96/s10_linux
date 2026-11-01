#!/bin/bash
# s10-terminal r1: keyboard auto-hide for USB keyboards, Volume Down toggle.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
cp "$T/s10-osk" "$P/s10-osk"
cat > "$P/s10-term" <<'EOF'
#!/bin/sh
# Terminal session for tty1: fbterm + tmux above the on-screen keyboard.
[ -f "$HOME/.fbtermrc" ] || cp /usr/share/s10-terminal/fbtermrc "$HOME/.fbtermrc"
export TERM=fbterm
if [ -e /run/s10-osk-hidden ]; then
	# keyboard hidden (USB keyboard or Volume Down): use the full height.
	# 1 px instead of 0 keeps fbterm scrolling by redraw, never by panning.
	export FBTERM_RESERVE_BOTTOM=1
else
	export FBTERM_RESERVE_BOTTOM=1100   # height of s10-osk
fi
exec fbterm -- tmux new -A -s main
EOF
cd "$P"
sed -i 's/^pkgrel=0$/pkgrel=1/' APKBUILD
python3 - <<'EOF'
import hashlib, re
p = "APKBUILD"; s = open(p).read()
for f in ("s10-osk", "s10-term"):
    h = hashlib.sha512(open(f, "rb").read()).hexdigest()
    s = re.sub(rf"^[0-9a-f]{{128}}  {re.escape(f)}$", f"{h}  {f}", s, flags=re.M)
open(p, "w").write(s)
EOF
python3 -m py_compile s10-osk && echo PY_OK
sh -n s10-term && echo SH_OK
grep -n '^pkgrel' APKBUILD
cd ../../..
git -c user.name=khan -c user.email=khan@localhost commit -qa -m "s10-terminal: keyboard state follows the running terminal at startup" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
