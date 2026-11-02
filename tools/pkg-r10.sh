#!/bin/bash
# s10-terminal r10: look and feel (theme, status bar, gestures, brightness, night mode,
# home screen, keyboard pop-ups/long-press/space swipe, boot splash). pkg/ is the source.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
S=/mnt/c/Users/irfan/Desktop/s10-postmarketos/pkg
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
cd "$S"
python3 - <<'EOF'
import re
s = open("APKBUILD").read()
s = re.sub(r"^pkgrel=\d+$", "pkgrel=10", s, flags=re.M)
if "s10-status" not in s:
    s = s.replace("\ts10-menu\n", "\ts10-menu\n\ts10-status\n\ts10-splash\n\ts10-splash.initd\n", 1)
    s = s.replace("for f in s10-osk s10-menu ", "for f in s10-osk s10-menu s10-status s10-splash ", 1)
    s = s.replace('\tinstall -Dm644 "$srcdir"/fbtermrc',
                  '\tinstall -Dm755 "$srcdir"/s10-splash.initd "$pkgdir"/etc/init.d/s10-splash\n'
                  '\tinstall -Dm644 "$srcdir"/fbtermrc', 1)
    s = s.rstrip('"\n') + "\nX  s10-status\nX  s10-splash\nX  s10-splash.initd\n\"\n"
open("APKBUILD", "w").write(s)
for f in ("s10-terminal.post-install", "s10-terminal.post-upgrade"):
    t = open(f).read()
    if "s10-splash" not in t:
        t = t.replace("rc-update -q add local default\n",
                      "rc-update -q add local default\nrc-update -q add s10-splash boot\n"
                      "rm -f /var/cache/s10-terminal/splash.rgb565   # re-rendered on next boot\n", 1)
        open(f, "w").write(t)
EOF
rm -rf "$P"/* && cp -a "$S"/. "$P"/
python3 "$T/resum.py" "$P" >/dev/null
cp "$P/APKBUILD" "$S/APKBUILD"
bash "$T/check-pkg.sh" | grep -v ok || true
grep -n 'pkgrel\|s10-status\|s10-splash' "$P/APKBUILD" "$P/s10-terminal.post-install"
cd "$P/../../.."
git add -A device/downstream/s10-terminal
git -c user.name=khan -c user.email=khan@localhost commit -q -m "s10-terminal: theme, status bar, touch gestures, brightness and night mode, home screen, keyboard pop-ups, boot splash" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
