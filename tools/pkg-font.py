#!/usr/bin/env python3
# Add the S10 VT font (and its OFL licence) to pkg/APKBUILD and refresh the font cache on install.
S = "/mnt/c/Users/irfan/Desktop/s10-postmarketos/pkg"
s = open(f"{S}/APKBUILD").read()
if "S10VT-Regular.ttf" not in s:
    s = s.replace("\tsshd-hardening.conf\n\t\"", "\tsshd-hardening.conf\n\tS10VT-Regular.ttf\n\tOFL-VT323.txt\n\t\"", 1)
    s = s.replace("license=\"MIT\"", "license=\"MIT AND OFL-1.1\"", 1)
    s = s.replace('\tinstall -Dm644 "$srcdir"/fbtermrc',
                  '\t# S10 VT: VT323 (OFL-1.1) plus box/block glyphs, built by tools/build-font.py\n'
                  '\tinstall -Dm644 "$srcdir"/S10VT-Regular.ttf "$pkgdir"/usr/share/fonts/s10-vt/S10VT-Regular.ttf\n'
                  '\tinstall -Dm644 "$srcdir"/OFL-VT323.txt "$pkgdir"/usr/share/licenses/$pkgname/OFL-VT323.txt\n'
                  '\tinstall -Dm644 "$srcdir"/fbtermrc', 1)
    s = s.rstrip('"\n') + "\nX  S10VT-Regular.ttf\nX  OFL-VT323.txt\n\"\n"
    open(f"{S}/APKBUILD", "w").write(s)
for f in ("s10-terminal.post-install", "s10-terminal.post-upgrade"):
    t = open(f"{S}/{f}").read()
    if "fc-cache" not in t:
        t = t.replace("exit 0", "fc-cache -f /usr/share/fonts/s10-vt >/dev/null 2>&1\nexit 0", 1)
        open(f"{S}/{f}", "w").write(t)
print("OK")
