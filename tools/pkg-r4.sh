#!/bin/bash
# s10-terminal r4: Syncthing for ~/notes and ~/journal, home network only.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
cd "$P"
cat > s10-syncthing.initd <<'EOF'
#!/sbin/openrc-run
# Syncthing as the phone user (uid 10000) for ~/notes and ~/journal.
# GUI/API on 127.0.0.1 only; discovery and relays are off (see s10-syncthing-setup).
description="Syncthing for the phone user, home network only"
user=$(getent passwd 10000 | cut -d: -f1)
supervisor=supervise-daemon
command=/usr/bin/syncthing
command_args="serve --no-browser --home=/home/$user/.config/syncthing --gui-address=127.0.0.1:8384"
command_user="$user:$user"
supervise_daemon_args="--env HOME=/home/$user"

depend() {
	need net
	after firewall local
}
EOF
cat > s10-syncthing-setup <<'EOF'
#!/bin/sh
# Run as the phone user once Syncthing is up: keep it on the home network only
# and make sure the shared folders exist. Safe to run again.
H="$HOME/.config/syncthing"
st() { syncthing cli --home="$H" "$@"; }
mkdir -p "$HOME/notes" "$HOME/journal"
st config options global-ann-enabled set false
st config options relays-enabled set false
st config options natenabled set false
st config options uraccepted set -- -1
st config options crash-reporting-enabled set false
st config options auto-upgrade-intervalh set 0
st config defaults folder path set "$HOME"
echo "Device ID: $(st show system | sed -n 's/.*"myID": "\(.*\)".*/\1/p')"
EOF
# firewall: Syncthing sync (22000 tcp/udp) and local discovery (21027 udp) from the home network
grep -q 22000 10-firewall.start || sed -i 's|^\$IPT -A INPUT -i wlan0 -s \$LAN -p tcp --dport 445 -j ACCEPT$|&\
$IPT -A INPUT -i wlan0 -s $LAN -p tcp --dport 22000 -j ACCEPT\
$IPT -A INPUT -i wlan0 -s $LAN -p udp --dport 22000 -j ACCEPT\
$IPT -A INPUT -i wlan0 -s $LAN -p udp --dport 21027 -j ACCEPT|' 10-firewall.start
grep -n 22000 10-firewall.start
python3 - <<'EOF'
import re
s = open("APKBUILD").read()
s = re.sub(r"^pkgrel=\d+$", "pkgrel=4", s, flags=re.M)
if "s10-syncthing" not in s:
    s = s.replace("\tpy3-pillow\n", "\tpy3-pillow\n\tsyncthing\n", 1)
    s = s.replace("\ts10-menu\n", "\ts10-menu\n\ts10-syncthing-setup\n\ts10-syncthing.initd\n", 1)
    s = s.replace("for f in s10-osk s10-menu ", "for f in s10-osk s10-menu s10-syncthing-setup ", 1)
    s = s.replace('\tinstall -Dm644 "$srcdir"/fbtermrc',
                  '\tinstall -Dm755 "$srcdir"/s10-syncthing.initd "$pkgdir"/etc/init.d/s10-syncthing\n'
                  '\tinstall -Dm644 "$srcdir"/fbtermrc', 1)
    s = s.rstrip('"\n') + "\nX  s10-syncthing-setup\nX  s10-syncthing.initd\n\"\n"
open("APKBUILD", "w").write(s)
for f in ("s10-terminal.post-install", "s10-terminal.post-upgrade"):
    t = open(f).read()
    if "s10-syncthing" not in t:
        t = re.sub(r"\n(exit 0\s*)?$", "\nrc-update add s10-syncthing default\n\\1", t.rstrip("\n") + "\n", count=1)
        open(f, "w").write(t)
EOF
python3 "$T/resum.py" . >/dev/null
grep -n 'pkgrel\|syncthing' APKBUILD s10-terminal.post-install s10-terminal.post-upgrade
sh -n s10-syncthing-setup && sh -n 10-firewall.start && echo SH_OK
cd ../../..
git add -A device/downstream/s10-terminal
git -c user.name=khan -c user.email=khan@localhost commit -q -m "s10-terminal: Syncthing for notes and journal, home network only" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
