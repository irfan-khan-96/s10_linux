#!/bin/bash
# s10-terminal r5: drop Syncthing again (service, setup script, firewall ports, dependency).
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
cd "$P"
git rm -q s10-syncthing.initd s10-syncthing-setup
sed -i '/--dport 22000 -j ACCEPT$/d; /--dport 21027 -j ACCEPT$/d' 10-firewall.start
python3 - <<'EOF'
import re
s = open("APKBUILD").read()
s = re.sub(r"^pkgrel=\d+$", "pkgrel=5", s, flags=re.M)
s = s.replace("\tsyncthing\n", "", 1)
s = s.replace("\ts10-syncthing-setup\n\ts10-syncthing.initd\n", "", 1)
s = s.replace("for f in s10-osk s10-menu s10-syncthing-setup ", "for f in s10-osk s10-menu ", 1)
s = s.replace('\tinstall -Dm755 "$srcdir"/s10-syncthing.initd "$pkgdir"/etc/init.d/s10-syncthing\n', "", 1)
s = re.sub(r"^\S+  s10-syncthing(-setup|\.initd)\n", "", s, flags=re.M)
open("APKBUILD", "w").write(s)
for f in ("s10-terminal.post-install", "s10-terminal.post-upgrade"):
    t = open(f).read().replace("rc-update add s10-syncthing default\n", "rc-update -q del s10-syncthing default 2>/dev/null\n")
    open(f, "w").write(t)
EOF
python3 "$T/resum.py" . >/dev/null
grep -n 'syncthing\|22000\|21027' APKBUILD 10-firewall.start s10-terminal.post-* || true
grep -n '^pkgrel' APKBUILD
