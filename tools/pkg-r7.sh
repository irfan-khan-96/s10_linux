#!/bin/bash
# s10-terminal r7: no gettys on tty2-6. Nothing shows those consoles (no fbcon), but Alt+arrow
# outside fbterm's raw mode could switch to one and leave fbterm on tty1 without input.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
cd "$P"
for f in s10-terminal.post-install s10-terminal.post-upgrade; do
	grep -q 'tty\[2-6\]' "$f" || python3 - "$f" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
old = '\tsed -i "s|^tty1::respawn:.*|tty1::respawn:/bin/su -l $user -c /usr/bin/s10-term|" /etc/inittab\n'
new = old + ('\t# no logins on tty2-6: nothing displays them, and switching there leaves fbterm without input\n'
             '\tsed -i "s|^tty[2-6]::|#&|" /etc/inittab\n'
             '\tkill -HUP 1 2>/dev/null\n')
assert s.count(old) == 1
open(p, "w").write(s.replace(old, new))
EOF
done
sed -i 's/^pkgrel=[0-9]*$/pkgrel=7/' APKBUILD
python3 "$T/resum.py" . >/dev/null
sh -n s10-terminal.post-install && sh -n s10-terminal.post-upgrade && echo SH_OK
grep -n 'tty\|pkgrel' s10-terminal.post-upgrade APKBUILD | head
cd ../../..
git -c user.name=khan -c user.email=khan@localhost commit -qam "s10-terminal: no gettys on tty2-6, so the console cannot switch away from fbterm" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
