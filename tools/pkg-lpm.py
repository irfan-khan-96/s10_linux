#!/usr/bin/env python3
# Add 05-s10-lpm.start to pkg/APKBUILD (sources and the local.d install loop).
p = "/mnt/c/Users/irfan/Desktop/s10-postmarketos/pkg/APKBUILD"
s = open(p).read()
if "05-s10-lpm" not in s:
    s = s.replace("\t10-firewall.start\n", "\t05-s10-lpm.start\n\t10-firewall.start\n", 1)
    s = s.replace("for f in 10-firewall ", "for f in 05-s10-lpm 10-firewall ", 1)
    s = s.rstrip('"\n') + "\nX  05-s10-lpm.start\n\"\n"
    open(p, "w").write(s)
print("OK" if "for f in 05-s10-lpm" in s else "install loop not found")
