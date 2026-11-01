#!/usr/bin/env python3
# Talk to the postmarketOS rescue shell over USB serial. Two readers share the
# port, so input often arrives scrambled: repeat each command until its success
# marker comes back, and guard the destructive step so a scrambled copy is a no-op.
import os, sys, time, tty, select, re, stat

DEV = "/dev/ttyACM0"
if not stat.S_ISCHR(os.stat(DEV).st_mode):
    sys.exit(f"{DEV} is not a serial device")
fd = os.open(DEV, os.O_RDWR | os.O_NOCTTY)
tty.setraw(fd)
log = open("/tmp/acm-session.log", "a")

def read_for(sec):
    out, end = b"", time.time() + sec
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], 0.1)
        if r:
            out += os.read(fd, 4096)
    text = out.decode(errors="replace")
    log.write(text); log.flush()
    return text

def send(line, wait=2.0):
    os.write(fd, b"\x15")               # Ctrl+U: drop any half-typed line
    time.sleep(0.2)
    os.write(fd, (line + "\r").encode())
    return read_for(wait)

def until(line, pattern, tries=25, wait=2.0):
    for i in range(tries):
        m = re.search(pattern, send(line, wait))
        if m:
            return m
    return None

read_for(1)
find = ("for f in /sys/class/block/*/uevent; do grep -qx PARTNAME=boot $f && "
        "echo BOOTDEV=$(basename $(dirname $f))=SIZE=$(cat $(dirname $f)/size)=END; done")
m = until(find, r"BOOTDEV=(sda\d+)=SIZE=(\d+)=END")
if not m:
    sys.exit("Could not read the BOOT partition; paste: cat -v /tmp/acm-session.log | tail -40")
dev, size = m.group(1), int(m.group(2))
print(f"BOOT partition: /dev/{dev}, {size * 512 // (1024*1024)} MiB")
if input("Wipe its first 1 MiB and reboot into Download mode? Type yes: ").strip() != "yes":
    sys.exit("Aborted, nothing changed.")

wipe = (f"D={dev}; grep -qx PARTNAME=boot /sys/class/block/$D/uevent && "
        f"dd if=/dev/zero of=/dev/$D bs=4096 count=256 && sync && echo WIPED=$D=OK")
if not until(wipe, rf"WIPED={dev}=OK", wait=4.0):
    sys.exit("Wipe did not confirm; nothing rebooted. Paste the log tail to Claude.")
print(f"/dev/{dev} wiped. Rebooting...")
for _ in range(15):
    try:
        send("reboot -f", 1.5)
    except OSError:
        break
print("Reboot sent. The phone should show Download mode in a few seconds.")
