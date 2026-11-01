#!/usr/bin/env python3
# Run on the phone as farmer: for 300 s, print gpio_keys events and changes of the reserve file.
import glob, os, select, struct, time
fd = None
for d in glob.glob("/sys/class/input/event*"):
    if open(d + "/device/name").read().strip() == "gpio_keys":
        fd = os.open("/dev/input/" + os.path.basename(d), os.O_RDONLY)
t0, last = time.monotonic(), None
def reserve():
    try: return open("/run/s10-osk-reserve").read().strip()
    except OSError: return "-"
while time.monotonic() - t0 < 300:
    r, _, _ = select.select([fd], [], [], 0.02)
    now = time.monotonic() - t0
    if r:
        data = os.read(fd, 24 * 16)
        for i in range(0, len(data), 24):
            sec, usec, etype, code, value = struct.unpack("qqHHi", data[i:i + 24])
            if etype == 1:
                print(f"{now:7.3f} key {code} value {value}", flush=True)
    res = reserve()
    if res != last:
        print(f"{now:7.3f} reserve {res}", flush=True); last = res
