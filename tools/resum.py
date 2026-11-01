#!/usr/bin/env python3
# Rewrite an APKBUILD's sha512sums for local sources, in source= order (abuild pairs them by position).
# Usage: resum.py <package dir>
import hashlib, os, re, sys
os.chdir(sys.argv[1])
s = open("APKBUILD").read()
src = re.search(r'^source="(.*?)"', s, re.S | re.M).group(1).split()
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
