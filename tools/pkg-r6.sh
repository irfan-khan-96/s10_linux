#!/bin/bash
# s10-terminal r6: screen wake with a 1 s pause (as tested by hand); plain unblank at startup.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
cd "$P"
python3 - <<'EOF'
s = open("s10-idle-blank").read()
old = '''def set_blank(off):
    if off:
        write_blank("1")
    else:
        # A plain unblank after a long blank can leave the panel dark (the driver
        # accepts it but DSIM stays off); off, a short pause, then on wakes it.
        write_blank("1")
        time.sleep(0.3)
        write_blank("0")
'''
new = '''def set_blank(off, cycle=True):
    if off:
        write_blank("1")
    elif cycle:
        # A plain unblank after a long blank can leave the panel dark (the driver
        # accepts it but DSIM stays off); off, 1 s for the panel to finish powering
        # down (0.3 s was too short), then on wakes it.
        write_blank("1")
        time.sleep(1.0)
        write_blank("0")
    else:
        write_blank("0")
'''
assert s.count(old) == 1
s = s.replace(old, new)
assert s.count("set_blank(False)\nwhile True:") == 1
s = s.replace("set_blank(False)\nwhile True:", "set_blank(False, cycle=False)\nwhile True:")
open("s10-idle-blank", "w").write(s)
import re
a = open("APKBUILD").read()
open("APKBUILD", "w").write(re.sub(r"^pkgrel=\d+$", "pkgrel=6", a, flags=re.M))
EOF
python3 "$T/resum.py" . >/dev/null
python3 -c "import ast; ast.parse(open('s10-idle-blank').read())" && echo OK
grep -n 'set_blank\|sleep' s10-idle-blank
cd ../../..
git -c user.name=khan -c user.email=khan@localhost commit -qam "s10-terminal: 1 s pause when waking the screen, plain unblank at startup" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
