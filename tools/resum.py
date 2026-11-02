#!/usr/bin/env python3
# Rewrite an APKBUILD's sha512sums for local sources, in source= order (abuild pairs them by position).
# Usage: resum.py <package dir>
import hashlib, os, re, sys
os.chdir(sys.argv[1])
s = open("APKBUILD").read()
src = re.search(r'^source="(.*?)"', s, re.S | re.M).group(1).split()
# expand simple variables ($pkgver, $_debrel, ...) as abuild would
vars_ = dict(re.findall(r"^(\w+)=([^\s\"']+)$", s, re.M))
src = [re.sub(r"\$\{?(\w+)\}?", lambda m: vars_.get(m.group(1), m.group(0)), e) for e in src]
old = dict(reversed(l.split("  ", 1)) for l in re.search(r'^sha512sums="(.*?)"', s, re.S | re.M).group(1).split("\n") if l.strip())
lines = []
for entry in src:
    name = entry.split("::")[0].rsplit("/", 1)[-1]
    if os.path.exists(name):
        lines.append(f"{hashlib.sha512(open(name, 'rb').read()).hexdigest()}  {name}")
    else:
        lines.append(f"{old[name]}  {name}")              # downloaded source: keep its sum
s = re.sub(r'^sha512sums=".*?"', 'sha512sums="\n' + "\n".join(lines) + '\n"', s, flags=re.S | re.M)
open("APKBUILD", "w").write(s)
print("\n".join(l[-40:] for l in lines))
