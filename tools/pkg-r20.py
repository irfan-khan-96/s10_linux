#!/usr/bin/env python3
# r20: supervised OpenRC services for s10-osk and s10-idle-blank (replacing the one-shot
# local.d scripts), plus /usr/bin/s10-update.
import os, re
S = "/mnt/c/Users/irfan/Desktop/s10-postmarketos/pkg"
s = open(f"{S}/APKBUILD").read()
if "s10-osk.initd" not in s:
    s = s.replace("\t50-s10-idle-blank.start\n", "", 1).replace("\t60-s10-osk.start\n", "", 1)
    s = s.replace(" 50-s10-idle-blank 60-s10-osk; do", "; do", 1)
    s = s.replace("\ts10-splash.initd\n", "\ts10-splash.initd\n\ts10-osk.initd\n\ts10-idle-blank.initd\n\ts10-update\n", 1)
    s = s.replace("for f in s10-osk s10-menu ", "for f in s10-osk s10-menu s10-update ", 1)
    s = s.replace('\tinstall -Dm755 "$srcdir"/s10-splash.initd "$pkgdir"/etc/init.d/s10-splash\n',
                  '\tinstall -Dm755 "$srcdir"/s10-splash.initd "$pkgdir"/etc/init.d/s10-splash\n'
                  '\tinstall -Dm755 "$srcdir"/s10-osk.initd "$pkgdir"/etc/init.d/s10-osk\n'
                  '\tinstall -Dm755 "$srcdir"/s10-idle-blank.initd "$pkgdir"/etc/init.d/s10-idle-blank\n', 1)
    s = re.sub(r"^\S+  (50-s10-idle-blank|60-s10-osk)\.start\n", "", s, flags=re.M)
    s = s.rstrip('"\n') + "\nX  s10-osk.initd\nX  s10-idle-blank.initd\nX  s10-update\n\"\n"
    open(f"{S}/APKBUILD", "w").write(s)
for f in ("s10-terminal.post-install", "s10-terminal.post-upgrade"):
    t = open(f"{S}/{f}").read()
    if "s10-osk default" not in t:
        t = t.replace("rc-update -q add s10-splash boot\n",
                      "rc-update -q add s10-splash boot\nrc-update -q add s10-idle-blank default\n"
                      "rc-update -q add s10-osk default\n", 1)
        open(f"{S}/{f}", "w").write(t)
for old in ("50-s10-idle-blank.start", "60-s10-osk.start"):
    if os.path.exists(f"{S}/{old}"):
        os.remove(f"{S}/{old}")
for needle in ("s10-osk.initd", "s10-update", "50-s10"):
    print(needle, needle in open(f"{S}/APKBUILD").read())
