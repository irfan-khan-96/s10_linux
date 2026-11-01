#!/bin/bash
# s10-terminal r5 (cont.): battery charge limit at boot, reliable screen wake.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
cd "$P"
cat > 45-s10-battery.start <<'EOF'
#!/bin/sh
# Stop charging at 85% (Samsung "Protect battery"); the phone lives on the charger.
# 0 = charge to 100%. Override with S10_CHARGE_LIMIT in /etc/conf.d/local.
echo "${S10_CHARGE_LIMIT:-85}" > /sys/class/power_supply/battery/batt_full_capacity
EOF
python3 - <<'EOF'
s = open("s10-idle-blank").read()
old = '''def set_blank(off):
    with open(BLANK, "w") as f:
        f.write("1" if off else "0")
'''
new = '''def write_blank(value):
    with open(BLANK, "w") as f:
        f.write(value)

def set_blank(off):
    if off:
        write_blank("1")
    else:
        # A plain unblank after a long blank can leave the panel dark (the driver
        # accepts it but DSIM stays off); off, a short pause, then on wakes it.
        write_blank("1")
        time.sleep(0.3)
        write_blank("0")
'''
assert s.count(old) == 1
s = s.replace(old, new)
open("s10-idle-blank", "w").write(s)
s = open("APKBUILD").read()
if "45-s10-battery" not in s:
    s = s.replace("\t40-s10-tuning.start\n", "\t40-s10-tuning.start\n\t45-s10-battery.start\n", 1)
    s = s.replace("40-s10-tuning 50-s10-idle-blank", "40-s10-tuning 45-s10-battery 50-s10-idle-blank", 1)
    s = s.rstrip('"\n') + "\nX  45-s10-battery.start\n\"\n"
open("APKBUILD", "w").write(s)
EOF
python3 "$T/resum.py" . >/dev/null
python3 -c "import ast; ast.parse(open('s10-idle-blank').read())" && sh -n 45-s10-battery.start && echo OK
grep -n 'battery\|pkgrel' APKBUILD
cd ../../..
git add -A device/downstream/s10-terminal
git -c user.name=khan -c user.email=khan@localhost commit -q -m "s10-terminal: drop Syncthing, 85% charge limit, reliable screen wake" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
